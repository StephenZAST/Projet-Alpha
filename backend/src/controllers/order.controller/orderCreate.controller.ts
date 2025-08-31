import { Request, Response } from 'express'; 
import prisma from '../../config/prisma';
import { 
  PricingService, 
  RewardsService, 
  NotificationService,
  SYSTEM_CONSTANTS
} from '../../services';
import { 
  NotificationType, 
  OrderStatus, 
  Order, 
  User,
  PaymentStatus,
  PaymentMethod,
  OrderItem as OrderItemType 
} from '../../models/types';
import { OrderSharedMethods } from './shared';
import { orderNotificationTemplates, getCustomerName } from '../../utils/notificationTemplates';
import { Prisma, order_status, recurrence_type, payment_method_enum } from '@prisma/client';

interface CreateOrderItemData {
  articleId: string;
  quantity: number;
  isPremium?: boolean;
}

interface OrderItem {
  orderId: string;
  articleId: string;
  serviceId: string;
  quantity: number; 
  unitPrice: number;
  createdAt: Date;
  updatedAt: Date;
}

interface Article {
  id: string;
  basePrice: number;
  premiumPrice: number;
}

export class OrderCreateController {
  static async createOrder(req: Request, res: Response) {
    console.log('[OrderController] Starting order creation');
    try {
      const { 
        serviceId, 
        addressId, 
        isRecurring, 
        recurrenceType, 
        collectionDate, 
        deliveryDate, 
        affiliateCode,
        items,
        paymentMethod,
        appliedOfferIds,
        serviceTypeId,
        userId: userIdFromPayload, // Correction ici
        note
      } = req.body;

      // Logique hybride :
      // - Si admin/superadmin ET userId fourni dans le payload, on l'utilise
      // - Sinon, on utilise l'utilisateur authentifié
      const isAdmin = req.user?.role === 'ADMIN' || req.user?.role === 'SUPER_ADMIN';
      const userId = isAdmin && userIdFromPayload ? userIdFromPayload : req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      // 1. Calculer le prix total avec les réductions
            // 1. Récupérer les offres actives auxquelles l'utilisateur est inscrit
            const userOffers = await prisma.offer_subscriptions.findMany({
              where: {
                userId,
                status: 'ACTIVE',
                offers: {
                  is_active: true,
                  startDate: { lte: new Date() },
                  endDate: { gte: new Date() }
                }
              },
              include: {
                offers: {
                  include: {
                    offer_articles: true
                  }
                }
              }
            });

            // 2. Filtrer les offres valides de façon flexible
            const validOffers = userOffers
              .map(sub => sub.offers)
              .filter((offer): offer is typeof offer => !!offer);

            const filteredValidOffers = validOffers.filter(offer => {
              if (!offer) return false;
              // Articles concernés : si la condition existe, on la vérifie, sinon on passe
              if (Array.isArray(offer.offer_articles) && offer.offer_articles.length > 0) {
                const offerArticleIds = offer.offer_articles.map(a => a.article_id);
                const hasValidArticle = items.some((item: any) => offerArticleIds.includes(item.articleId));
                if (!hasValidArticle) return false;
              }
              // Montant minimum d'achat : si défini et > 0, on vérifie, sinon on passe
              if (typeof offer.minPurchaseAmount === 'number' && offer.minPurchaseAmount > 0) {
                const subtotal = items.reduce((sum: number, item: any) => sum + (item.unitPrice || 0) * item.quantity, 0);
                if (subtotal < offer.minPurchaseAmount) return false;
              }
              // Dates de validité : si définies, on vérifie, sinon on passe
              if (offer.startDate && new Date() < new Date(offer.startDate)) return false;
              if (offer.endDate && new Date() > new Date(offer.endDate)) return false;
              return true;
            });

            // 3. Séparer cumulables et non-cumulables
            const cumulableOffers = filteredValidOffers.filter(o => o && o.isCumulative === true);
            const nonCumulableOffers = filteredValidOffers.filter(o => o && o.isCumulative === false);

            // 4. Appliquer la meilleure offre non-cumulable (si présente), sinon toutes les cumulables
            let appliedOffers = [];
            if (nonCumulableOffers.length) {
              // Prendre la plus avantageuse
              const bestOffer = nonCumulableOffers.reduce((max, offer) => {
                if (!offer || !max) return max || offer;
                return (Number(offer.discountValue) > Number(max.discountValue)) ? offer : max;
              }, nonCumulableOffers[0]);
              appliedOffers = bestOffer ? [bestOffer] : [];
            } else {
              appliedOffers = cumulableOffers;
            }

            // 5. Calculer le prix total avec les réductions
            const pricing = await PricingService.calculateOrderTotal({
              items,
              userId,
              appliedOfferIds: appliedOffers.filter((o): o is NonNullable<typeof o> => !!o && typeof o.id === 'string').map(o => o.id)
            });
      // 2. Créer la commande avec le montant total
      const order = await prisma.orders.create({
        data: {
          userId,
          serviceId,
          addressId,
          isRecurring,
          recurrenceType,
          nextRecurrenceDate: null,
          totalAmount: pricing.total,
          collectionDate,
          deliveryDate,
          affiliateCode,
          paymentMethod,
          status: 'PENDING',
          service_type_id: serviceTypeId,
          createdAt: new Date(),
          updatedAt: new Date()
        }
      });

      // Création de la note unique (si fournie)
      let noteRecord = null;
      if (note && typeof note === 'string' && note.trim().length > 0) {
        noteRecord = await prisma.order_notes.create({
          data: {
            order_id: order.id,
            note,
            created_at: new Date(),
            updated_at: new Date()
          }
        });
      }


      // 3. Récupérer les prix réels des couples article/service/serviceType/service
      // IMPORTANT : Le couple prix DOIT matcher sur le trio (article_id, service_type_id, service_id) !
      // Si on ne filtre pas sur les trois, on peut récupérer un prix d'un autre service ou d'un autre couple, ce qui fausse le calcul.
      // Cette subtilité est source de bugs fréquents : TOUJOURS filtrer sur les trois clés pour garantir le bon prix.
      const couplePrices = await prisma.article_service_prices.findMany({
        where: {
          article_id: { in: items.map((item: CreateOrderItemData) => item.articleId) },
          service_type_id: serviceTypeId,
          service_id: serviceId
        }
      });
      // On log les couples trouvés pour debug (à retirer en prod)
      console.log('[OrderController] Couples prix utilisés (ids):', couplePrices.map(c => c.id));
      const couplePriceMap = new Map<string, { base_price: number; premium_price: number }>(
        couplePrices
          .filter(c => c.article_id)
          .map(c => [c.article_id as string, { base_price: Number(c.base_price), premium_price: Number(c.premium_price) }])
      );

      // 4. Créer les items de commande avec le bon prix
      const mappedItems = items.map((item: CreateOrderItemData) => {
        const couple = couplePriceMap.get(item.articleId);
        const unitPrice = couple
          ? (item.isPremium ? couple.premium_price : couple.base_price)
          : 1; // fallback si pas trouvé
        return {
          orderId: order.id,
          articleId: item.articleId,
          serviceId,
          quantity: item.quantity,
          unitPrice,
          createdAt: new Date(),
          updatedAt: new Date(),
          isPremium: item.isPremium ?? false
        };
      });
      console.log('[OrderController] Payload order_items (mapped with couple prices):', mappedItems);
      await prisma.order_items.createMany({
        data: mappedItems
      });

      // 5. Si code affilié, créer transaction de commission
      if (affiliateCode) {
        const affiliate = await prisma.affiliate_profiles.findUnique({
          where: { affiliate_code: affiliateCode }
        });

        if (affiliate) {
          await prisma.commission_transactions.create({
            data: {
              affiliate_id: affiliate.id,
              order_id: order.id,
              amount: pricing.total * Number(affiliate.commission_rate || 0) / 100,
              status: 'PENDING'
            }
          });
        }
      }

      // 6. Récupérer la commande complète avec relations
      const orderData = await prisma.orders.findUnique({
        where: { id: order.id },
        include: {
          user: true,
          address: true,
          order_items: {
            include: {
              article: true
            }
          }
        }
      });
      const noteUnique = noteRecord?.note || null;

      if (!orderData) {
        throw new Error('Failed to retrieve complete order');
      }

      const formattedOrder: Order = {
        id: orderData.id,
        userId: orderData.userId,
        service_id: orderData.serviceId || '',
        address_id: orderData.addressId || '',
        affiliateCode: orderData.affiliateCode || undefined,
        status: orderData.status || 'PENDING',
        isRecurring: orderData.isRecurring || false,
        recurrenceType: orderData.recurrenceType || null,
        nextRecurrenceDate: orderData.nextRecurrenceDate || undefined,
        totalAmount: Number(orderData.totalAmount || 0),
        collectionDate: orderData.collectionDate || undefined,
        deliveryDate: orderData.deliveryDate || undefined,
        createdAt: orderData.createdAt || new Date(),
        updatedAt: orderData.updatedAt || new Date(),
        service_type_id: orderData.service_type_id,
        paymentStatus: PaymentStatus.PENDING,
        paymentMethod: orderData.paymentMethod as PaymentMethod || PaymentMethod.CASH,
        items: orderData.order_items.map(item => ({
          id: item.id,
          orderId: item.orderId,
          articleId: item.articleId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          unitPrice: Number(item.unitPrice),
          isPremium: item.isPremium ?? undefined,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
          article: item.article ? {
            id: item.article.id,
            categoryId: item.article.categoryId || '',
            name: item.article.name,
            description: item.article.description || '',
            basePrice: Number(item.article.basePrice),
            premiumPrice: Number(item.article.premiumPrice || 0),
            createdAt: item.article.createdAt || new Date(),
            updatedAt: item.article.updatedAt || new Date()
          } : undefined
        })),
        note: noteUnique
      };

      // 7. Traiter les points et notifications
      const earnedPoints = Math.floor(pricing.total * SYSTEM_CONSTANTS.POINTS.ORDER_MULTIPLIER);
      await RewardsService.processOrderPoints(userId, formattedOrder, 'ORDER');

      const user: User = {
        id: orderData.user.id,
        email: orderData.user.email,
        firstName: orderData.user.first_name,
        lastName: orderData.user.last_name,
        phone: orderData.user.phone || undefined,
        role: orderData.user.role || 'CLIENT',
        password: '',
        createdAt: orderData.user.created_at || new Date(),
        updatedAt: orderData.user.updated_at || new Date()
      };

      const notificationTemplate = orderNotificationTemplates.orderCreated(
        formattedOrder,
        user
      );

      await NotificationService.createNotification(
        userId,
        NotificationType.ORDER_CREATED,
        notificationTemplate.message,
        notificationTemplate.data
      );

      // 8. Préparer et envoyer la réponse
      const response = {
        order: formattedOrder,
        pricing,
        rewards: {
          pointsEarned: earnedPoints,
          currentBalance: await OrderSharedMethods.getUserPoints(userId)
        }
      };

      res.status(201).json({ data: response });

    } catch (error: any) {
      console.error('[OrderController] Error creating order:', error);
      res.status(500).json({ 
        error: error.message || 'Error creating order',
        details: process.env.NODE_ENV === 'development' ? error : undefined
      });
    }
  }

  static async calculateTotal(req: Request, res: Response) {
    try {
      const { items, appliedOfferIds } = req.body;
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const pricing = await PricingService.calculateOrderTotal({
        items,
        userId,
        appliedOfferIds
      });

      res.json({ data: pricing });
    } catch (error: any) {
      console.error('[OrderController] Error calculating total:', error);
      res.status(500).json({ error: error.message });
    }
  }
}
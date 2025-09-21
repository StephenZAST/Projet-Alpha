export * from './pricing.service';
export * from './rewards.service'; 
export * from './notification.service';
export { LoyaltyService } from './loyalty.service';
export { LoyaltyAdminService } from './loyaltyAdmin.service';
export { PricingService } from './pricing.service';
export { RewardsService } from './rewards.service';
export { NotificationService } from './notification.service';

// Types utilitaires pour l'intégration des services
export interface OrderCalculationResult {
  subtotal: number;
  discounts: Array<{
    offerId: string;
    amount: number;
    type: 'OFFER' | 'POINTS' | 'AFFILIATE';
  }>;
  total: number;
  earnedPoints: number;
  commission?: {
    affiliateId: string;
    amount: number;
  };
} 

// Exemple d'utilisation des services ensemble :
/*
import { PricingService, RewardsService, NotificationService } from './services';

// Dans votre OrderController :
async function createOrder(orderData) {
  // 1. Calculer le prix avec les réductions
  const pricing = await PricingService.calculateOrderTotal({
    items: orderData.items,
    userId: orderData.userId,
    appliedOfferIds: orderData.offerIds
  });

  // 2. Créer la commande en base...

  // 3. Traiter les points et commissions
  await RewardsService.processOrderPoints(orderData.userId, order);
  if (order.affiliateCode) {
    await RewardsService.processAffiliateCommission(order);
  }

  // 4. Envoyer les notifications
  await NotificationService.createOrderNotification(
    orderData.userId,
    order.id,
    'ORDER_CREATED'
  );

  return {
    order,
    pricing,
    notifications: 'Sent'
  };
}
*/

// Constantes utiles
export const SYSTEM_CONSTANTS = {
  POINTS: {
    CONVERSION_RATE: 1, // 1 point = 1 unité monétaire
    MIN_POINTS_EXCHANGE: 100, // Minimum de points pour une conversion
    ORDER_MULTIPLIER: 0.1 // 10% du montant en points
  },
  COMMISSION: {
    DEFAULT_RATE: 0.1, // 10% de commission standard
    SECONDARY_RATE: 0.01, // 1% pour les affiliés parents
    MIN_WITHDRAWAL: 100 // Montant minimum pour un retrait
  },
  NOTIFICATIONS: {
    DEFAULT_TEMPLATES: {
      ORDER_CREATED: "Votre commande {orderId} a été créée avec succès",
      ORDER_STATUS_UPDATED: "Le statut de votre commande {orderId} est maintenant : {status}",
      POINTS_EARNED: "Vous avez gagné {points} points de fidélité !",
      COMMISSION_EARNED: "Vous avez gagné une commission de {amount} sur la commande {orderId}"
    }
  }
};
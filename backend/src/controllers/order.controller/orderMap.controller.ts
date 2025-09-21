import { Request, Response } from 'express';
import prisma from '../../config/prisma';
import { order_status } from '@prisma/client';

export class OrderMapController {
  /**
   * Récupère les commandes avec leurs coordonnées GPS pour affichage sur carte
   */
  static async getOrdersForMap(req: Request, res: Response) {
    try {
      const {
        status,
        startDate,
        endDate,
        collectionDateStart,
        collectionDateEnd,
        deliveryDateStart,
        deliveryDateEnd,
        isFlashOrder,
        serviceTypeId,
        paymentMethod,
        city,
        postalCode,
        bounds // Pour limiter aux commandes dans la zone visible de la carte
      } = req.query;

      console.log('[OrderMapController] Getting orders for map with filters:', {
        status,
        startDate,
        endDate,
        collectionDateStart,
        collectionDateEnd,
        deliveryDateStart,
        deliveryDateEnd,
        isFlashOrder,
        serviceTypeId,
        paymentMethod,
        city,
        postalCode,
        bounds
      });

      // Construction des filtres
      const whereClause: any = {
        // Exclure les commandes sans adresse ou sans coordonnées GPS
        address: {
          AND: [
            { gps_latitude: { not: null } },
            { gps_longitude: { not: null } }
          ]
        }
      };

      // Filtre par statut
      if (status && status !== 'all') {
        whereClause.status = status.toString().toUpperCase() as order_status;
      }

      // Filtre par date de création
      if (startDate || endDate) {
        whereClause.createdAt = {};
        if (startDate) {
          whereClause.createdAt.gte = new Date(startDate as string);
        }
        if (endDate) {
          whereClause.createdAt.lte = new Date(endDate as string);
        }
      }

      // Filtre par date de collecte
      if (collectionDateStart || collectionDateEnd) {
        whereClause.collectionDate = {};
        if (collectionDateStart) {
          whereClause.collectionDate.gte = new Date(collectionDateStart as string);
        }
        if (collectionDateEnd) {
          whereClause.collectionDate.lte = new Date(collectionDateEnd as string);
        }
      }

      // Filtre par date de livraison
      if (deliveryDateStart || deliveryDateEnd) {
        whereClause.deliveryDate = {};
        if (deliveryDateStart) {
          whereClause.deliveryDate.gte = new Date(deliveryDateStart as string);
        }
        if (deliveryDateEnd) {
          whereClause.deliveryDate.lte = new Date(deliveryDateEnd as string);
        }
      }

      // Filtre commande flash
      if (isFlashOrder !== undefined) {
        whereClause.order_metadata = {
          is_flash_order: isFlashOrder === 'true'
        };
      }

      // Filtre par type de service
      if (serviceTypeId && serviceTypeId !== 'all') {
        whereClause.service_type_id = serviceTypeId as string;
      }

      // Filtre par méthode de paiement
      if (paymentMethod && paymentMethod !== 'all') {
        whereClause.paymentMethod = paymentMethod as string;
      }

      // Filtre par ville
      if (city) {
        whereClause.address.city = {
          contains: city as string,
          mode: 'insensitive'
        };
      }

      // Filtre par code postal
      if (postalCode) {
        whereClause.address.postal_code = {
          contains: postalCode as string
        };
      }

      // Filtre par bounds de la carte (optionnel pour optimiser les performances)
      if (bounds) {
        try {
          const boundsObj = JSON.parse(bounds as string);
          if (boundsObj.north && boundsObj.south && boundsObj.east && boundsObj.west) {
            whereClause.address.AND.push({
              gps_latitude: {
                gte: parseFloat(boundsObj.south),
                lte: parseFloat(boundsObj.north)
              }
            });
            whereClause.address.AND.push({
              gps_longitude: {
                gte: parseFloat(boundsObj.west),
                lte: parseFloat(boundsObj.east)
              }
            });
          }
        } catch (e) {
          console.warn('[OrderMapController] Invalid bounds format:', bounds);
        }
      }

      // Récupération des commandes avec leurs données essentielles
      const orders = await prisma.orders.findMany({
        where: whereClause,
        select: {
          id: true,
          status: true,
          totalAmount: true,
          createdAt: true,
          collectionDate: true,
          deliveryDate: true,
          paymentMethod: true,
          affiliateCode: true,
          address: {
            select: {
              id: true,
              name: true,
              street: true,
              city: true,
              postal_code: true,
              gps_latitude: true,
              gps_longitude: true
            }
          },
          user: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          service_types: {
            select: {
              id: true,
              name: true,
              description: true
            }
          },
          order_metadata: {
            select: {
              is_flash_order: true,
              metadata: true
            }
          },
          order_items: {
            select: {
              id: true,
              quantity: true,
              unitPrice: true,
              isPremium: true,
              weight: true,
              article: {
                select: {
                  id: true,
                  name: true,
                  description: true
                }
              }
            }
          }
        },
        orderBy: {
          createdAt: 'desc'
        },
        // Limiter le nombre de résultats pour éviter la surcharge
        take: 1000
      });

      // Transformation des données pour la carte
      const mapOrders = orders.map((order: any) => ({
        id: order.id,
        status: order.status,
        totalAmount: order.totalAmount,
        createdAt: order.createdAt,
        collectionDate: order.collectionDate,
        deliveryDate: order.deliveryDate,
        paymentMethod: order.paymentMethod,
        affiliateCode: order.affiliateCode,
        isFlashOrder: order.order_metadata?.is_flash_order || false,
        coordinates: {
          latitude: parseFloat(order.address?.gps_latitude?.toString() || '0'),
          longitude: parseFloat(order.address?.gps_longitude?.toString() || '0')
        },
        address: {
          id: order.address?.id,
          name: order.address?.name,
          street: order.address?.street,
          city: order.address?.city,
          postalCode: order.address?.postal_code
        },
        client: {
          id: order.user.id,
          firstName: order.user.first_name,
          lastName: order.user.last_name,
          email: order.user.email,
          phone: order.user.phone
        },
        serviceType: {
          id: order.service_types.id,
          name: order.service_types.name,
          description: order.service_types.description
        },
        itemsCount: order.order_items.length,
        totalWeight: order.order_items.reduce((sum: number, item: any) => sum + (parseFloat(item.weight?.toString() || '0')), 0),
        items: order.order_items.map((item: any) => ({
          id: item.id,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          isPremium: item.isPremium,
          weight: item.weight,
          article: {
            id: item.article.id,
            name: item.article.name,
            description: item.article.description
          }
        }))
      }));

      // Statistiques pour la carte
      const stats = {
        total: mapOrders.length,
        byStatus: mapOrders.reduce((acc: Record<string, number>, order: any) => {
          acc[order.status] = (acc[order.status] || 0) + 1;
          return acc;
        }, {} as Record<string, number>),
        byPaymentMethod: mapOrders.reduce((acc: Record<string, number>, order: any) => {
          acc[order.paymentMethod] = (acc[order.paymentMethod] || 0) + 1;
          return acc;
        }, {} as Record<string, number>),
        flashOrders: mapOrders.filter((o: any) => o.isFlashOrder).length,
        totalAmount: mapOrders.reduce((sum: number, order: any) => sum + parseFloat(order.totalAmount?.toString() || '0'), 0)
      };

      console.log(`[OrderMapController] Found ${mapOrders.length} orders for map display`);

      res.json({
        success: true,
        data: {
          orders: mapOrders,
          stats,
          count: mapOrders.length
        }
      });

    } catch (error: any) {
      console.error('[OrderMapController] Error getting orders for map:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la récupération des commandes pour la carte',
        message: error.message
      });
    }
  }

  /**
   * Récupère les statistiques géographiques des commandes
   */
  static async getOrdersGeoStats(req: Request, res: Response) {
    try {
      const {
        status,
        startDate,
        endDate,
        isFlashOrder
      } = req.query;

      console.log('[OrderMapController] Getting geo stats with filters:', {
        status,
        startDate,
        endDate,
        isFlashOrder
      });

      const whereClause: any = {
        address: {
          AND: [
            { gps_latitude: { not: null } },
            { gps_longitude: { not: null } }
          ]
        }
      };

      // Appliquer les mêmes filtres que pour getOrdersForMap
      if (status && status !== 'all') {
        whereClause.status = status.toString().toUpperCase() as order_status;
      }

      if (startDate || endDate) {
        whereClause.createdAt = {};
        if (startDate) {
          whereClause.createdAt.gte = new Date(startDate as string);
        }
        if (endDate) {
          whereClause.createdAt.lte = new Date(endDate as string);
        }
      }

      if (isFlashOrder !== undefined) {
        whereClause.order_metadata = {
          is_flash_order: isFlashOrder === 'true'
        };
      }

      // Statistiques par ville
      const cityStats = await prisma.orders.groupBy({
        by: ['addressId'],
        where: whereClause,
        _count: {
          id: true
        },
        _sum: {
          totalAmount: true
        }
      });

      // Récupérer les détails des adresses pour les villes
      const addressIds = cityStats.map((stat: any) => stat.addressId).filter(Boolean);
      const addresses = await prisma.addresses.findMany({
        where: {
          id: { in: addressIds as string[] }
        },
        select: {
          id: true,
          city: true,
          gps_latitude: true,
          gps_longitude: true
        }
      });

      // Grouper par ville
      const cityStatsMap = new Map();
      cityStats.forEach((stat: any) => {
        const address = addresses.find((addr: any) => addr.id === stat.addressId);
        if (address && address.city) {
          const city = address.city;
          if (!cityStatsMap.has(city)) {
            cityStatsMap.set(city, {
              city,
              count: 0,
              totalAmount: 0,
              coordinates: {
                latitude: parseFloat(address.gps_latitude?.toString() || '0'),
                longitude: parseFloat(address.gps_longitude?.toString() || '0')
              }
            });
          }
          const cityData = cityStatsMap.get(city);
          cityData.count += stat._count.id;
          cityData.totalAmount += parseFloat(stat._sum.totalAmount?.toString() || '0');
        }
      });

      const geoStats = {
        byCity: Array.from(cityStatsMap.values()),
        totalCities: cityStatsMap.size,
        totalOrders: cityStats.reduce((sum: number, stat: any) => sum + stat._count.id, 0),
        totalAmount: cityStats.reduce((sum: number, stat: any) => sum + parseFloat(stat._sum.totalAmount?.toString() || '0'), 0)
      };

      res.json({
        success: true,
        data: geoStats
      });

    } catch (error: any) {
      console.error('[OrderMapController] Error getting geo stats:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la récupération des statistiques géographiques',
        message: error.message
      });
    }
  }
}
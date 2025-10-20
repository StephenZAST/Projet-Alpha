"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SYSTEM_CONSTANTS = exports.NotificationService = exports.RewardsService = exports.PricingService = exports.LoyaltyAdminService = exports.LoyaltyService = void 0;
__exportStar(require("./pricing.service"), exports);
__exportStar(require("./rewards.service"), exports);
__exportStar(require("./notification.service"), exports);
var loyalty_service_1 = require("./loyalty.service");
Object.defineProperty(exports, "LoyaltyService", { enumerable: true, get: function () { return loyalty_service_1.LoyaltyService; } });
var loyaltyAdmin_service_1 = require("./loyaltyAdmin.service");
Object.defineProperty(exports, "LoyaltyAdminService", { enumerable: true, get: function () { return loyaltyAdmin_service_1.LoyaltyAdminService; } });
var pricing_service_1 = require("./pricing.service");
Object.defineProperty(exports, "PricingService", { enumerable: true, get: function () { return pricing_service_1.PricingService; } });
var rewards_service_1 = require("./rewards.service");
Object.defineProperty(exports, "RewardsService", { enumerable: true, get: function () { return rewards_service_1.RewardsService; } });
var notification_service_1 = require("./notification.service");
Object.defineProperty(exports, "NotificationService", { enumerable: true, get: function () { return notification_service_1.NotificationService; } });
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
exports.SYSTEM_CONSTANTS = {
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

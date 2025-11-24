# 🔔 Système de Notifications - Spécifications Complètes

**Date de création:** 16 Octobre 2025  
**Version:** 1.0  
**Objectif:** Définir toutes les notifications critiques par feature et par rôle  
**Status:** 🎯 Recommandations d'Implémentation

---

## 📋 Table des Matières

1. [Introduction & Principes](#introduction--principes)
2. [Notifications Loyalty/Rewards](#notifications-loyaltyrewards)
3. [Notifications Commandes](#notifications-commandes)
4. [Notifications Livraison](#notifications-livraison)
5. [Notifications Affiliation](#notifications-affiliation)
6. [Notifications Abonnement](#notifications-abonnement)
7. [Notifications Admin](#notifications-admin)
8. [Architecture Technique](#architecture-technique)
9. [Priorités d'Implémentation](#priorités-dimplémentation)
10. [Matrice de Récapitulatif](#matrice-de-récapitulatif)

---

## 🎯 Introduction & Principes

### Philosophie des Notifications

**Principe #1: NÉCESSAIRES SEULEMENT**
```
❌ PAS DE: "Bienvenue sur Alpha!"
✅ OUI: "Votre commande prête à récupérer"

❌ PAS DE: "Vous avez 100 points!" (après chaque achat)
✅ OUI: "Vous pouvez maintenant réclamer une récompense"

❌ PAS DE: Notifications toutes les heures
✅ OUI: Notifications aux moments critiques
```

### Critères de Pertinence

Une notification doit répondre à **au moins 2** de ces critères:

| Critère | Explication | Exemple |
|---------|------------|---------|
| **Action immédiate** | Client doit agir MAINTENANT | "Commande prête à chercher" |
| **Information critique** | Client a besoin de savoir | "Paiement échoué" |
| **Changement d'état** | Situation a changé | "Status livraison: Livrée" |
| **Opportunité limitée** | Temps limité/stock limité | "Offre expire dans 2h" |
| **Feedback utilisateur** | Confirmation action utilisateur | "Récompense réclamée avec succès" |
| **Blocage/Risque** | Problème qui empêche utilisation | "Compte suspendu" |

---

## 🎁 Notifications Loyalty/Rewards

### NOTIFICATION 1: Reward Claim Approval ⭐ CRITÈRE

**Qui:** CLIENT  
**Quand:** Admin approuve une demande de récompense  
**Priorité:** HAUTE (Action immédiate)

```typescript
{
  id: "notification-reward-approved",
  featureName: "LOYALTY",
  type: "REWARD_CLAIM_APPROVED",
  targetRole: "CLIENT",
  
  // Quand se déclencher
  triggerEvent: "reward_claim.status_updated",
  triggerCondition: {
    field: "status",
    oldValue: "PENDING",
    newValue: "APPROVED"
  },
  
  // Contenu
  title: "🎉 Votre récompense est approuvée!",
  body: "Votre récompense '{rewardName}' a été approuvée. Vous pouvez maintenant l'utiliser.",
  
  // Actions
  actions: [
    {
      label: "Voir la récompense",
      action: "navigate",
      target: "rewards_details",
      params: { rewardId: "{rewardId}" }
    }
  ],
  
  // Delai
  sendDelay: "IMMEDIATE",
  
  // Canaux
  channels: ["PUSH", "IN_APP"],
  
  // Frequence
  frequency: "ONCE",
  
  metadata: {
    priority: "HIGH",
    actionRequired: true,
    criticalityScore: 9,
    reason: "Client attend confirmation pour utiliser reward"
  }
}
```

**Template Message:**
```
📱 Push: "🎉 {rewardName} approuvée! Allez la réclamer"
📧 Email: "Bonne nouvelle! Votre demande de récompense {rewardName} a été approuvée. 
           Vous pouvez maintenant l'utiliser sur votre prochaine commande."
💬 In-App: Badge "1 new reward" + Toast notification
```

**Raison:** ✅ NÉCESSAIRE
- Action immédiate (client peut l'utiliser)
- Changement d'état important
- Feedback sur action antérieure
- Crée engagement immédiat

---

### NOTIFICATION 2: Reward Claim Rejection ⭐ CRITÈRE

**Qui:** CLIENT  
**Quand:** Admin rejette une demande de récompense  
**Priorité:** MOYENNE (Important mais pas urgent)

```typescript
{
  id: "notification-reward-rejected",
  featureName: "LOYALTY",
  type: "REWARD_CLAIM_REJECTED",
  targetRole: "CLIENT",
  
  triggerEvent: "reward_claim.status_updated",
  triggerCondition: {
    field: "status",
    oldValue: "PENDING",
    newValue: "REJECTED"
  },
  
  title: "ℹ️ Votre demande de récompense a été rejetée",
  body: "Raison: {rejectionReason}. Vos points ont été remboursés. {supportLink}",
  
  actions: [
    {
      label: "Voir les points",
      action: "navigate",
      target: "loyalty_dashboard"
    },
    {
      label: "Contacter support",
      action: "open_url",
      target: "support_chat"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP", "EMAIL"],
  frequency: "ONCE",
  
  metadata: {
    priority: "MEDIUM",
    actionRequired: false,
    criticalityScore: 7,
    reason: "Client doit savoir pourquoi + points remboursés"
  }
}
```

**Raison:** ✅ NÉCESSAIRE
- Points ont été remboursés (changement d'état)
- Client doit connaître la raison
- Évite frustration/confusion

---

### NOTIFICATION 3: Milestone Points Reached ⭐ OPTIONAL (Engagement)

**Qui:** CLIENT  
**Quand:** Client atteint un palier de points (10k, 20k, 50k)  
**Priorité:** BASSE (Motivationnel)

```typescript
{
  id: "notification-points-milestone",
  featureName: "LOYALTY",
  type: "POINTS_MILESTONE_REACHED",
  targetRole: "CLIENT",
  
  triggerEvent: "loyalty_points.balance_updated",
  triggerCondition: {
    pointsBalance: [10000, 20000, 50000, 100000],  // Milestones
    comparison: "REACHES_OR_EXCEEDS"
  },
  
  title: "🏆 Palier déverrouillé: {milestoneName}",
  body: "Vous avez atteint {pointsBalance} points! De meilleures récompenses vous attendent.",
  
  actions: [
    {
      label: "Voir les récompenses",
      action: "navigate",
      target: "rewards_catalog"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "ONCE_PER_MILESTONE",
  
  metadata: {
    priority: "LOW",
    actionRequired: false,
    criticalityScore: 5,
    reason: "Engaagement/Gamification - pas critique",
    canBeOptedOut: true
  }
}
```

**Raison:** ✅ OPTIONNEL (Engagement)
- Motivationnel pour client
- Crée sensation de progression
- Peut être désactivé dans préférences

**⚠️ À NE PAS FAIRE:**
```
❌ "Vous avez gagné 150 points sur cette commande"
   → Trop fréquent, évident au dashboard

❌ "Vous avez 2500 points disponibles"
   → Redondant avec app dashboard
```

---

### NOTIFICATION 4: Reward Claiming Used ✅ CONFIRMÉE

**Qui:** CLIENT + ADMIN  
**Quand:** Client utilise une récompense réclamée sur une commande  
**Priorité:** HAUTE (Confirmationimportante)

```typescript
{
  id: "notification-reward-used",
  featureName: "LOYALTY",
  type: "REWARD_CLAIM_USED",
  targetRole: ["CLIENT", "ADMIN"],
  
  triggerEvent: "reward_claim.status_updated",
  triggerCondition: {
    field: "status",
    oldValue: "APPROVED",
    newValue: "USED"
  },
  
  // CLIENT notification
  clientNotification: {
    title: "✅ Récompense utilisée",
    body: "Votre récompense {rewardName} a été appliquée à la commande #{orderId}",
    channels: ["PUSH", "IN_APP"],
    sendDelay: "IMMEDIATE"
  },
  
  // ADMIN notification
  adminNotification: {
    title: "📊 Récompense utilisée par {clientName}",
    body: "{rewardName} ({pointsValue} pts) - Commande #{orderId}",
    channels: ["IN_APP"],
    sendDelay: "IMMEDIATE"
  },
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 8,
    reason: "Confirme utilisation, important pour audit"
  }
}
```

**Raison:** ✅ NÉCESSAIRE
- Confirmation que reward a été utilisé
- Important pour client (suivi)
- Important pour admin (audit trail)

---

### NOTIFICATION 5: Reward Expiring Soon ⏰ OPTIONNEL

**Qui:** CLIENT  
**Quand:** Reward approuvée expira dans 7 jours  
**Priorité:** MOYENNE-BASSE

```typescript
{
  id: "notification-reward-expiring",
  featureName: "LOYALTY",
  type: "REWARD_CLAIM_EXPIRING_SOON",
  targetRole: "CLIENT",
  
  triggerEvent: "scheduled_job.check_expiring_rewards",
  triggerCondition: {
    daysUntilExpiry: 7
  },
  
  title: "⏰ Votre récompense expire bientôt",
  body: "{rewardName} expire dans 7 jours. Utilisez-la avant de la perdre!",
  
  actions: [
    {
      label: "Utiliser maintenant",
      action: "navigate",
      target: "place_order"
    }
  ],
  
  sendDelay: "SCHEDULED",
  sendTime: "09:00",  // 9am
  channels: ["PUSH", "IN_APP"],
  frequency: "ONCE",
  
  metadata: {
    priority: "MEDIUM",
    criticalityScore: 6,
    reason: "Prévention perte de valeur",
    canBeOptedOut: true
  }
}
```

**Raison:** ✅ OPTIONNEL (Mais utile)
- Prévient client de perte
- Encourage utilisation rapide
- Peut être opt-out

---

## 📦 Notifications Commandes

### NOTIFICATION 6: Order Placed Confirmation ⭐ CRITÈRE

**Qui:** CLIENT + ADMIN  
**Quand:** Commande créée avec succès  
**Priorité:** HAUTE

```typescript
{
  id: "notification-order-placed",
  featureName: "ORDERS",
  type: "ORDER_PLACED",
  targetRole: ["CLIENT", "ADMIN"],
  
  triggerEvent: "order.created",
  triggerCondition: {
    status: "PENDING"
  },
  
  // CLIENT notification
  clientNotification: {
    title: "✅ Commande confirmée",
    body: "Commande #{orderId} reçue. Montant: {totalAmount} FCFA",
    actions: [
      {
        label: "Suivi de la commande",
        action: "navigate",
        target: "order_tracking",
        params: { orderId: "{orderId}" }
      }
    ],
    channels: ["PUSH", "IN_APP", "EMAIL"],
    sendDelay: "IMMEDIATE"
  },
  
  // ADMIN notification
  adminNotification: {
    title: "📥 Nouvelle commande reçue",
    body: "#{orderId} de {clientName} - {totalAmount} FCFA",
    channels: ["PUSH", "IN_APP"],
    sendDelay: "IMMEDIATE",
    importance: "HIGH"
  },
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 10,
    reason: "Confirmation transaction"
  }
}
```

**Template:**
```
🤳 Push Client: "Commande #12345 confirmée - 25 000 FCFA"
💼 Push Admin: "Nouvelle commande #12345 - 25 000 FCFA"
📧 Email Client: Récapitulatif complet + lien suivi
```

---

### NOTIFICATION 7: Payment Failed ⭐ CRITÈRE

**Qui:** CLIENT + ADMIN  
**Quand:** Paiement a échoué  
**Priorité:** TRÈS HAUTE (Blocage)

```typescript
{
  id: "notification-payment-failed",
  featureName: "ORDERS",
  type: "PAYMENT_FAILED",
  targetRole: ["CLIENT", "ADMIN"],
  
  triggerEvent: "order.payment_failed",
  triggerCondition: {
    paymentStatus: "FAILED"
  },
  
  clientNotification: {
    title: "❌ Paiement échoué",
    body: "Votre paiement pour la commande #{orderId} a échoué.\nRaison: {failureReason}\nVeuillez réessayer ou contacter le support.",
    actions: [
      {
        label: "Réessayer le paiement",
        action: "navigate",
        target: "order_payment",
        params: { orderId: "{orderId}" }
      },
      {
        label: "Contacter support",
        action: "open_url",
        target: "support_chat"
      }
    ],
    channels: ["PUSH", "IN_APP", "EMAIL"],
    sendDelay: "IMMEDIATE",
    importance: "CRITICAL"
  },
  
  adminNotification: {
    title: "⚠️ Paiement échoué - {clientName}",
    body: "Commande #{orderId} - Raison: {failureReason}",
    channels: ["PUSH", "IN_APP"],
    sendDelay: "IMMEDIATE"
  },
  
  metadata: {
    priority: "CRITICAL",
    criticalityScore: 10,
    reason: "Blocage transaction - action requise"
  }
}
```

---

### NOTIFICATION 8: Order Status Changed ⭐ CRITÈRE

**Qui:** CLIENT + DELIVERY  
**Quand:** Status de commande change  
**Priorité:** HAUTE

```typescript
{
  id: "notification-order-status-changed",
  featureName: "ORDERS",
  type: "ORDER_STATUS_CHANGED",
  targetRole: ["CLIENT", "DELIVERY", "ADMIN"],
  
  triggerEvent: "order.status_updated",
  
  // Mapping des notifications par status
  statusNotifications: {
    "PENDING -> PROCESSING": {
      clientMessage: "📋 Votre commande est en cours de traitement",
      deliveryMessage: "📝 Nouvelle commande à traiter: #{orderId}",
      clientChannels: ["PUSH", "IN_APP"],
      deliveryChannels: ["PUSH"]
    },
    
    "PROCESSING -> READY": {
      clientMessage: "🎉 Votre commande est prête! Venez la chercher.",
      deliveryMessage: "✅ Commande prête pour livraison: #{orderId}",
      clientChannels: ["PUSH", "EMAIL"],
      deliveryChannels: ["PUSH"],
      clientActions: ["View Order", "Schedule Pickup"]
    },
    
    "READY -> DELIVERING": {
      clientMessage: "🚗 Votre commande est en route! Livreur: {driverName}",
      deliveryMessage: "🚙 Commande en route: #{orderId}",
      clientChannels: ["PUSH", "IN_APP"],
      deliveryChannels: ["IN_APP"]
    },
    
    "DELIVERING -> DELIVERED": {
      clientMessage: "✅ Commande livrée! Merci de votre confiance.",
      deliveryMessage: "✔️ Commande livrée: #{orderId}",
      clientChannels: ["PUSH", "IN_APP"],
      deliveryChannels: ["IN_APP"]
    }
  },
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Updates essentiels de status"
  }
}
```

**Raison:** ✅ NÉCESSAIRE
- Client suit sa commande
- Livreur sait ce qu'il doit faire
- Changements d'état importants

---

### NOTIFICATION 9: Order Ready for Pickup ⭐ CRITÈRE

**Qui:** CLIENT  
**Quand:** Commande prête et client doit venir chercher  
**Priorité:** HAUTE (Action requise)

```typescript
{
  id: "notification-order-ready-pickup",
  featureName: "ORDERS",
  type: "ORDER_READY_FOR_PICKUP",
  targetRole: "CLIENT",
  
  triggerEvent: "order.status_updated",
  triggerCondition: {
    deliveryType: "PICKUP",
    status: "READY"
  },
  
  title: "🎯 Votre commande est prête!",
  body: "Commande #{orderId} prête. Venez la chercher avant {pickupDeadline}",
  
  actions: [
    {
      label: "Voir les horaires",
      action: "navigate",
      target: "order_details"
    },
    {
      label: "Je viens la chercher",
      action: "navigate",
      target: "confirm_pickup"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "EMAIL"],
  frequency: "ONCE",
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Action immédiate requise"
  }
}
```

---

### NOTIFICATION 10: Order Reminder ⏰ OPTIONNEL

**Qui:** CLIENT  
**Quand:** Commande prête depuis 2 jours (reminder)  
**Priorité:** BASSE (Gentil rappel)

```typescript
{
  id: "notification-order-reminder",
  featureName: "ORDERS",
  type: "ORDER_READY_REMINDER",
  targetRole: "CLIENT",
  
  triggerEvent: "scheduled_job.check_uncollected_orders",
  triggerCondition: {
    status: "READY",
    daysSinceReady: 2
  },
  
  title: "⏰ N'oubliez pas votre commande!",
  body: "Commande #{orderId} vous attend depuis 2 jours.",
  
  sendDelay: "SCHEDULED",
  sendTime: "14:00",  // 2pm
  channels: ["PUSH"],
  frequency: "ONCE_THEN_DAILY_FOR_3_DAYS",
  
  metadata: {
    priority: "LOW",
    criticalityScore: 4,
    reason: "Rappel non-agressif",
    canBeOptedOut: true
  }
}
```

---

### NOTIFICATION 11: Order Cancelled ⭐ CRITÈRE

**Qui:** CLIENT + ADMIN  
**Quand:** Commande annulée  
**Priorité:** HAUTE (Changement important)

```typescript
{
  id: "notification-order-cancelled",
  featureName: "ORDERS",
  type: "ORDER_CANCELLED",
  targetRole: ["CLIENT", "ADMIN"],
  
  triggerEvent: "order.status_updated",
  triggerCondition: {
    status: "CANCELLED"
  },
  
  clientNotification: {
    title: "❌ Commande annulée",
    body: "Commande #{orderId} annulée. Raison: {cancellationReason}\nRemboursement traité.",
    actions: [
      {
        label: "Voir le statut du remboursement",
        action: "navigate",
        target: "order_details"
      }
    ],
    channels: ["PUSH", "IN_APP", "EMAIL"]
  },
  
  adminNotification: {
    title: "⛔ Commande annulée",
    body: "#{orderId} de {clientName} - Raison: {cancellationReason}",
    channels: ["PUSH", "IN_APP"]
  },
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Changement état + remboursement"
  }
}
```

---

## 🚚 Notifications Livraison

### NOTIFICATION 12: Delivery Assignment ⭐ CRITÈRE

**Qui:** DELIVERY PERSON  
**Quand:** Commande assignée à un livreur  
**Priorité:** HAUTE

```typescript
{
  id: "notification-delivery-assigned",
  featureName: "DELIVERY",
  type: "DELIVERY_ASSIGNED",
  targetRole: "DELIVERY",
  
  triggerEvent: "delivery.assigned_to_driver",
  
  title: "📦 Nouvelle livraison assignée",
  body: "Commande #{orderId} assignée - {clientName}\nAdresse: {address}\nTél: {clientPhone}",
  
  actions: [
    {
      label: "Voir détails",
      action: "navigate",
      target: "delivery_details",
      params: { orderId: "{orderId}" }
    },
    {
      label: "Accepter",
      action: "confirm_delivery"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH"],
  frequency: "ONCE",
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Action immédiate - travail assigné"
  }
}
```

---

### NOTIFICATION 13: Delivery Location Update 📍 OPTIONAL

**Qui:** CLIENT  
**Quand:** Livreur est en route (update location)  
**Priorité:** BASSE-MOYENNE (Utile mais pas critique)

```typescript
{
  id: "notification-driver-nearby",
  featureName: "DELIVERY",
  type: "DRIVER_NEARBY",
  targetRole: "CLIENT",
  
  triggerEvent: "delivery.location_updated",
  triggerCondition: {
    distanceToClient: "< 5 km"
  },
  
  title: "🚗 Livreur à proximité",
  body: "Livreur à {distance}km. Sera chez vous dans environ {eta} minutes",
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "ONCE_WHEN_NEAR",
  
  metadata: {
    priority: "MEDIUM",
    criticalityScore: 6,
    reason: "Info utile pour client se préparer",
    canBeOptedOut: true
  }
}
```

---

### NOTIFICATION 14: Delivery Completed ✅ CONFIRMÉE

**Qui:** CLIENT + ADMIN  
**Quand:** Livraison confirmée complétée  
**Priorité:** HAUTE

```typescript
{
  id: "notification-delivery-completed",
  featureName: "DELIVERY",
  type: "DELIVERY_COMPLETED",
  targetRole: ["CLIENT", "ADMIN"],
  
  triggerEvent: "order.status_updated",
  triggerCondition: {
    status: "DELIVERED"
  },
  
  clientNotification: {
    title: "✅ Commande livrée",
    body: "Commande #{orderId} livrée avec succès. Merci!",
    actions: [
      {
        label: "Laisser un avis",
        action: "navigate",
        target: "review_order"
      }
    ],
    channels: ["PUSH", "IN_APP"],
    sendDelay: "IMMEDIATE"
  },
  
  adminNotification: {
    title: "✔️ Livraison complétée",
    body: "#{orderId} livrée - {driverName}",
    channels: ["IN_APP"]
  },
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 8,
    reason: "Confirmation completion"
  }
}
```

---

### NOTIFICATION 15: Delivery Problem ⚠️ CRITIQUE

**Qui:** DELIVERY + CLIENT + ADMIN  
**Quand:** Problème lors de livraison (client absent, accident, etc)  
**Priorité:** CRITIQUE

```typescript
{
  id: "notification-delivery-problem",
  featureName: "DELIVERY",
  type: "DELIVERY_PROBLEM",
  targetRole: ["DELIVERY", "CLIENT", "ADMIN"],
  
  triggerEvent: "delivery.problem_reported",
  
  problems: {
    "CLIENT_ABSENT": {
      clientNotification: "🚪 Impossible de trouver quelqu'un. Que voulez-vous faire?",
      deliveryNotification: "⚠️ Client absent",
      adminNotification: "🚨 Problème de livraison - client absent"
    },
    "WRONG_ADDRESS": {
      clientNotification: "❓ Adresse non trouvée. Pouvez-vous confirmer?",
      deliveryNotification: "❓ Adresse introuvable",
      adminNotification: "⚠️ Problème d'adresse - #{orderId}"
    },
    "DAMAGED_GOODS": {
      clientNotification: "😞 Marchandise endommagée. Nous allons arranger ça.",
      deliveryNotification: "🚨 Marchandise endommagée",
      adminNotification: "🚨 Marchandise endommagée - #{orderId}"
    }
  },
  
  channels: ["PUSH", "IN_APP"],
  sendDelay: "IMMEDIATE",
  
  metadata: {
    priority: "CRITICAL",
    criticalityScore: 10,
    reason: "Action immédiate requise"
  }
}
```

---

## 🤝 Notifications Affiliation

### NOTIFICATION 16: Referral Code Used ✅ CONFIRMÉE

**Qui:** AFFILIATE  
**Quand:** Client utilise le code d'un affilié  
**Priorité:** HAUTE (Argent à gagner)

```typescript
{
  id: "notification-referral-used",
  featureName: "AFFILIATION",
  type: "REFERRAL_CODE_USED",
  targetRole: "AFFILIATE",
  
  triggerEvent: "order.created_with_affiliate_code",
  
  title: "💰 Nouveau client par votre code!",
  body: "{newClientName} a utilisé votre code '{affiliateCode}'",
  
  actions: [
    {
      label: "Voir mes commissions",
      action: "navigate",
      target: "affiliate_dashboard"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "EVERY_TIME",
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Affilié doit savoir revenue généré"
  }
}
```

---

### NOTIFICATION 17: Commission Earned ⭐ CRITÈRE

**Qui:** AFFILIATE  
**Quand:** Commande complétée = commission confirmée  
**Priorité:** HAUTE

```typescript
{
  id: "notification-commission-earned",
  featureName: "AFFILIATION",
  type: "COMMISSION_EARNED",
  targetRole: "AFFILIATE",
  
  triggerEvent: "order.delivered",
  triggerCondition: {
    affiliateCode: "EXISTS",
    commissionCalculated: true
  },
  
  title: "💸 Commission gagnée!",
  body: "Commission de {commissionAmount} FCFA confirmée pour commande #{orderId}",
  
  actions: [
    {
      label: "Voir détails",
      action: "navigate",
      target: "commission_details"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "EVERY_TIME",
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Affilié attend confirmation revenue"
  }
}
```

---

### NOTIFICATION 18: Withdrawal Approved ⭐ CRITÈRE

**Qui:** AFFILIATE  
**Quand:** Admin approuve demande de retrait  
**Priorité:** HAUTE

```typescript
{
  id: "notification-withdrawal-approved",
  featureName: "AFFILIATION",
  type: "WITHDRAWAL_APPROVED",
  targetRole: "AFFILIATE",
  
  triggerEvent: "affiliate_withdrawal.approved",
  
  title: "✅ Retrait approuvé!",
  body: "Votre retrait de {withdrawalAmount} FCFA a été approuvé. Paiement en cours...",
  
  actions: [
    {
      label: "Voir le statut",
      action: "navigate",
      target: "withdrawal_status"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP", "EMAIL"],
  frequency: "ONCE",
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Argent approuvé - affilié suit statut"
  }
}
```

---

### NOTIFICATION 19: Withdrawal Rejected ⭐ CRITÈRE

**Qui:** AFFILIATE  
**Quand:** Admin rejette demande de retrait  
**Priorité:** HAUTE

```typescript
{
  id: "notification-withdrawal-rejected",
  featureName: "AFFILIATION",
  type: "WITHDRAWAL_REJECTED",
  targetRole: "AFFILIATE",
  
  triggerEvent: "affiliate_withdrawal.rejected",
  
  title: "❌ Retrait rejeté",
  body: "Votre demande de retrait a été rejetée.\nRaison: {rejectionReason}\nContactez le support.",
  
  actions: [
    {
      label: "Contacter support",
      action: "open_url",
      target: "support_chat"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "ONCE",
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 8,
    reason: "Important - raison du rejet"
  }
}
```

---

### NOTIFICATION 20: Level Up 🏆 ENGAGEMENT

**Qui:** AFFILIATE  
**Quand:** Affilié monte de niveau (plus d'avantages)  
**Priorité:** MOYENNE (Engagement)

```typescript
{
  id: "notification-affiliate-level-up",
  featureName: "AFFILIATION",
  type: "AFFILIATE_LEVEL_UP",
  targetRole: "AFFILIATE",
  
  triggerEvent: "affiliate_profile.level_updated",
  triggerCondition: {
    newLevel: "> oldLevel"
  },
  
  title: "🎉 Nouveau niveau déverrouillé!",
  body: "Vous êtes passé à niveau {newLevel}! Commission: {newCommissionRate}%",
  
  actions: [
    {
      label: "Voir les avantages",
      action: "navigate",
      target: "affiliate_levels"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "ONCE_PER_LEVEL",
  
  metadata: {
    priority: "MEDIUM",
    criticalityScore: 7,
    reason: "Engagement + nouveaux avantages"
  }
}
```

---

## 📋 Notifications Abonnement

### NOTIFICATION 21: Subscription Confirmed ⭐ CRITÈRE

**Qui:** CLIENT + ADMIN  
**Quand:** Client souscrit à un plan  
**Priorité:** HAUTE

```typescript
{
  id: "notification-subscription-confirmed",
  featureName: "SUBSCRIPTION",
  type: "SUBSCRIPTION_ACTIVATED",
  targetRole: ["CLIENT", "ADMIN"],
  
  triggerEvent: "subscription.created",
  
  clientNotification: {
    title: "✅ Abonnement activé",
    body: "Bienvenue! Vous êtes maintenant abonné à {planName}.\nVous recevrez {benefit1}, {benefit2}...",
    channels: ["PUSH", "IN_APP", "EMAIL"],
    sendDelay: "IMMEDIATE"
  },
  
  adminNotification: {
    title: "📊 Nouvel abonnement",
    body: "{clientName} abonné à {planName}",
    channels: ["IN_APP"]
  },
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Confirmation transaction importante"
  }
}
```

---

### NOTIFICATION 22: Renewal Coming ⏰ OPTIONNEL

**Qui:** CLIENT  
**Quand:** Abonnement renouvellé dans 7 jours  
**Priorité:** BASSE-MOYENNE

```typescript
{
  id: "notification-subscription-renewing",
  featureName: "SUBSCRIPTION",
  type: "SUBSCRIPTION_RENEWING_SOON",
  targetRole: "CLIENT",
  
  triggerEvent: "scheduled_job.check_expiring_subscriptions",
  triggerCondition: {
    daysUntilRenewal: 7
  },
  
  title: "📅 Votre abonnement se renouvelle dans 7 jours",
  body: "Abonnement {planName} renouvellera le {renewalDate}.\nMontant: {amount} FCFA",
  
  actions: [
    {
      label: "Gérer l'abonnement",
      action: "navigate",
      target: "subscription_settings"
    }
  ],
  
  sendDelay: "SCHEDULED",
  channels: ["PUSH", "IN_APP"],
  frequency: "ONCE",
  
  metadata: {
    priority: "MEDIUM",
    criticalityScore: 5,
    reason: "Info de transparence",
    canBeOptedOut: true
  }
}
```

---

### NOTIFICATION 23: Subscription Cancelled ⭐ CRITÈRE

**Qui:** CLIENT + ADMIN  
**Quand:** Abonnement annulé  
**Priorité:** HAUTE

```typescript
{
  id: "notification-subscription-cancelled",
  featureName: "SUBSCRIPTION",
  type: "SUBSCRIPTION_CANCELLED",
  targetRole: ["CLIENT", "ADMIN"],
  
  triggerEvent: "subscription.cancelled",
  
  clientNotification: {
    title: "ℹ️ Abonnement annulé",
    body: "Votre abonnement {planName} a été annulé. Vous conservez vos bénéfices jusqu'à {endDate}.",
    channels: ["PUSH", "IN_APP", "EMAIL"]
  },
  
  adminNotification: {
    title: "📉 Abonnement annulé",
    body: "{clientName} - {planName}",
    channels: ["IN_APP"]
  },
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 8,
    reason: "Changement statut important"
  }
}
```

---

## 👨‍💼 Notifications Admin

### NOTIFICATION 24: New Order Alert ⭐ CRITÈRE

**Qui:** ADMIN  
**Quand:** Nouvelle commande reçue  
**Priorité:** HAUTE

```typescript
{
  id: "notification-admin-new-order",
  featureName: "ADMIN",
  type: "NEW_ORDER_RECEIVED",
  targetRole: "ADMIN",
  
  triggerEvent: "order.created",
  
  title: "📥 Nouvelle commande",
  body: "#{orderId} de {clientName} - {totalAmount} FCFA",
  
  actions: [
    {
      label: "Voir commande",
      action: "navigate",
      target: "admin_order_details"
    },
    {
      label: "Traiter",
      action: "navigate",
      target: "order_processing"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "EVERY_TIME",
  
  metadata: {
    priority: "HIGH",
    criticalityScore: 9,
    reason: "Action requise"
  }
}
```

---

### NOTIFICATION 25: Payment Issue Alert ⚠️ CRITIQUE

**Qui:** ADMIN  
**Quand:** Plusieurs paiements échouent ou charge requise  
**Priorité:** CRITIQUE

```typescript
{
  id: "notification-admin-payment-issue",
  featureName: "ADMIN",
  type: "PAYMENT_SYSTEM_ISSUE",
  targetRole: "ADMIN",
  
  triggerEvent: "payment.multiple_failures | payment.system_error",
  
  title: "🚨 Problème système de paiement",
  body: "{failureCount} paiements échoués. Vérifier système de paiement.",
  
  actions: [
    {
      label: "Voir les détails",
      action: "navigate",
      target: "payment_logs"
    },
    {
      label: "Contacter support",
      action: "open_url",
      target: "payment_provider_support"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP", "EMAIL"],
  frequency: "ONCE_THEN_HOURLY",
  
  metadata: {
    priority: "CRITICAL",
    criticalityScore: 10,
    reason: "System issue - action immédiate"
  }
}
```

---

### NOTIFICATION 26: Low Stock/Inventory ⚠️ MOYENNE

**Qui:** ADMIN  
**Quand:** Ressources basses (peu de colis, produits)  
**Priorité:** MOYENNE

```typescript
{
  id: "notification-admin-low-inventory",
  featureName: "ADMIN",
  type: "LOW_INVENTORY",
  targetRole: "ADMIN",
  
  triggerEvent: "inventory.threshold_reached",
  
  title: "📦 Stock faible",
  body: "{itemName} seulement {quantity} unités restantes",
  
  actions: [
    {
      label: "Voir inventaire",
      action: "navigate",
      target: "inventory_management"
    }
  ],
  
  sendDelay: "IMMEDIATE",
  channels: ["PUSH", "IN_APP"],
  frequency: "ONCE_PER_ITEM",
  
  metadata: {
    priority: "MEDIUM",
    criticalityScore: 6,
    reason: "Alerte de stock"
  }
}
```

---

### NOTIFICATION 27: High Reward Claims ℹ️ INFO

**Qui:** ADMIN  
**Quand:** Demandes de récompenses élevées (> seuil journalier)  
**Priorité:** BASSE-MOYENNE

```typescript
{
  id: "notification-admin-high-reward-claims",
  featureName: "ADMIN",
  type: "HIGH_REWARD_CLAIMS",
  targetRole: "ADMIN",
  
  triggerEvent: "reward_claim.daily_volume_exceeded",
  triggerCondition: {
    dailyClaimsCount: "> 100"
  },
  
  title: "ℹ️ Volume récompenses élevé",
  body: "{claimsCount} récompenses réclamées aujourd'hui. Budget utilisé: {budgetUsed}%",
  
  actions: [
    {
      label: "Voir les détails",
      action: "navigate",
      target: "reward_analytics"
    }
  ],
  
  sendDelay: "SCHEDULED",
  sendTime: "18:00",  // 6pm daily
  channels: ["IN_APP"],
  frequency: "DAILY",
  
  metadata: {
    priority: "LOW",
    criticalityScore: 4,
    reason: "Info analytics - pas urgent"
  }
}
```

---

## 🔧 Architecture Technique

### Structure de Base

```typescript
interface Notification {
  id: string;
  featureName: string;
  type: NotificationType;
  targetRole: Role | Role[];
  
  // Trigger
  triggerEvent: string;
  triggerCondition?: Record<string, any>;
  
  // Contenu
  title: string;
  body: string;
  actions?: NotificationAction[];
  
  // Sending
  sendDelay: "IMMEDIATE" | "SCHEDULED";
  sendTime?: string;  // HH:mm format
  channels: Channel[];  // PUSH, EMAIL, IN_APP, SMS
  frequency: Frequency;
  
  // Metadata
  metadata: {
    priority: "LOW" | "MEDIUM" | "HIGH" | "CRITICAL";
    criticalityScore: number;  // 1-10
    reason: string;
    actionRequired: boolean;
    canBeOptedOut: boolean;
  };
}
```

### Channels & Priorités

```typescript
enum Channel {
  PUSH = "PUSH",              // Mobile push notification
  EMAIL = "EMAIL",            // Email
  IN_APP = "IN_APP",          // In-app banner/notification
  SMS = "SMS"                 // SMS (coûteux - utiliser prudemment)
}

enum Priority {
  LOW = 1,        // Nice to know
  MEDIUM = 2,     // Should know
  HIGH = 3,       // Must know
  CRITICAL = 4    // Action required NOW
}
```

### Frequency Rules

```typescript
enum Frequency {
  ONCE = "ONCE",                                    // Une fois seulement
  ONCE_PER_DAY = "ONCE_PER_DAY",                    // Max une fois/jour
  ONCE_PER_WEEK = "ONCE_PER_WEEK",                  // Max une fois/semaine
  EVERY_TIME = "EVERY_TIME",                        // Chaque événement
  ONCE_THEN_DAILY = "ONCE_THEN_DAILY",              // Puis daily si non traité
  ONCE_THEN_DAILY_FOR_3_DAYS = "ONCE_THEN_DAILY_FOR_3_DAYS",  // Puis daily 3x
  ONCE_PER_MILESTONE = "ONCE_PER_MILESTONE",        // Une fois par palier
  DAILY = "DAILY",                                  // Quotidienne
  SCHEDULED = "SCHEDULED"                           // À heure fixe
}
```

### Implementation Points

**1. Event Triggers (Backend):**
```typescript
// src/services/notificationService.ts

export class NotificationService {
  
  // Event emitters
  static async onOrderCreated(order: Order) {
    await this.sendNotification({
      type: "ORDER_PLACED",
      targetRoles: ["CLIENT", "ADMIN"],
      data: { order }
    });
  }
  
  static async onRewardClaimApproved(claim: RewardClaim) {
    await this.sendNotification({
      type: "REWARD_CLAIM_APPROVED",
      targetRole: "CLIENT",
      data: { claim }
    });
  }
  
  // Generic send
  static async sendNotification(config: NotificationConfig) {
    // Route to correct channels
    // PUSH → Firebase Cloud Messaging
    // EMAIL → Email service
    // IN_APP → WebSocket to user
    // SMS → Twilio/African service
  }
}
```

**2. User Preferences:**
```typescript
interface NotificationPreferences {
  userId: string;
  
  // General opt-out
  disableAllNotifications: boolean;
  
  // By channel
  channels: {
    PUSH: { enabled: boolean };
    EMAIL: { enabled: boolean };
    IN_APP: { enabled: boolean };
    SMS: { enabled: boolean };
  };
  
  // By feature
  features: {
    LOYALTY: { enabled: boolean };
    ORDERS: { enabled: boolean };
    DELIVERY: { enabled: boolean };
    AFFILIATION: { enabled: boolean };
  };
  
  // By type
  types: {
    REWARD_CLAIM_APPROVED: { enabled: boolean };
    ORDER_PLACED: { enabled: boolean };
    // ... all notification types
  };
  
  // Quiet hours
  quietHours: {
    enabled: boolean;
    startTime: "22:00";  // 10pm
    endTime: "08:00";    // 8am
  };
}
```

---

## 🎯 Priorités d'Implémentation

### Phase 1: CRITIQUE (Week 1)
```
🚨 À faire immédiatement:

1. ✅ Order notifications (1-11)
   ├─ ORDER_PLACED
   ├─ PAYMENT_FAILED
   ├─ ORDER_STATUS_CHANGED
   └─ ORDER_READY_PICKUP

2. ✅ Loyalty notifications (1-2)
   ├─ REWARD_CLAIM_APPROVED
   └─ REWARD_CLAIM_REJECTED

3. ✅ Delivery notifications (12-14)
   ├─ DELIVERY_ASSIGNED
   ├─ DELIVERY_COMPLETED
   └─ DELIVERY_PROBLEM

Channels: PUSH + IN_APP (simples, pas EMAIL/SMS encore)
```

### Phase 2: HAUTE (Week 2-3)
```
⭐ Important pour UX:

4. ✅ Affiliate notifications (16-19)
   ├─ REFERRAL_CODE_USED
   ├─ COMMISSION_EARNED
   └─ WITHDRAWAL_APPROVED/REJECTED

5. ✅ Subscription notifications (21, 23)
   ├─ SUBSCRIPTION_CONFIRMED
   └─ SUBSCRIPTION_CANCELLED

6. ✅ Admin critical alerts (24-25)
   ├─ NEW_ORDER_ALERT
   └─ PAYMENT_ISSUE_ALERT

Channels: PUSH + IN_APP + EMAIL (notifications importantes)
```

### Phase 3: ENGAGEMENT (Week 4+)
```
💡 Optionnel - engagement/gamification:

7. ✅ Milestone notifications (3)
   └─ POINTS_MILESTONE_REACHED

8. ✅ Reminder/expiring (5, 10, 22)
   ├─ REWARD_EXPIRING_SOON
   ├─ ORDER_REMINDER
   └─ SUBSCRIPTION_RENEWING

9. ✅ Analytics (26-27)
   ├─ LOW_INVENTORY
   └─ HIGH_REWARD_CLAIMS

Channels: PUSH (less intrusive)
Opt-out: Toujours disponible
```

---

## 📊 Matrice de Récapitulatif

### Toutes les Notifications

| # | Feature | Type | Client | Admin | Delivery | Affiliate | Priority | Channels | Phase |
|---|---------|------|--------|-------|----------|-----------|----------|----------|-------|
| 1 | Loyalty | Reward Approved | ✅ | - | - | - | HIGH | PUSH, IN_APP | 1 |
| 2 | Loyalty | Reward Rejected | ✅ | - | - | - | HIGH | PUSH, IN_APP, EMAIL | 1 |
| 3 | Loyalty | Points Milestone | ✅ | - | - | - | LOW | PUSH | 3 |
| 4 | Loyalty | Reward Used | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP | 2 |
| 5 | Loyalty | Reward Expiring | ✅ | - | - | - | MEDIUM | PUSH | 3 |
| 6 | Orders | Order Placed | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP, EMAIL | 1 |
| 7 | Orders | Payment Failed | ✅ | ✅ | - | - | CRITICAL | PUSH, IN_APP, EMAIL | 1 |
| 8 | Orders | Status Changed | ✅ | ✅ | ✅ | - | HIGH | PUSH, IN_APP | 1 |
| 9 | Orders | Ready Pickup | ✅ | - | - | - | HIGH | PUSH, EMAIL | 1 |
| 10 | Orders | Reminder | ✅ | - | - | - | LOW | PUSH | 3 |
| 11 | Orders | Cancelled | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP, EMAIL | 1 |
| 12 | Delivery | Assigned | - | - | ✅ | - | HIGH | PUSH | 1 |
| 13 | Delivery | Driver Nearby | ✅ | - | - | - | MEDIUM | PUSH, IN_APP | 2 |
| 14 | Delivery | Completed | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP | 1 |
| 15 | Delivery | Problem | ✅ | ✅ | ✅ | - | CRITICAL | PUSH, IN_APP | 1 |
| 16 | Affiliate | Referral Used | - | - | - | ✅ | HIGH | PUSH, IN_APP | 2 |
| 17 | Affiliate | Commission Earned | - | - | - | ✅ | HIGH | PUSH, IN_APP | 2 |
| 18 | Affiliate | Withdrawal Approved | - | - | - | ✅ | HIGH | PUSH, IN_APP, EMAIL | 2 |
| 19 | Affiliate | Withdrawal Rejected | - | - | - | ✅ | HIGH | PUSH, IN_APP | 2 |
| 20 | Affiliate | Level Up | - | - | - | ✅ | MEDIUM | PUSH, IN_APP | 3 |
| 21 | Subscription | Activated | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP, EMAIL | 2 |
| 22 | Subscription | Renewing | ✅ | - | - | - | MEDIUM | PUSH, IN_APP | 3 |
| 23 | Subscription | Cancelled | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP, EMAIL | 2 |
| 24 | Admin | New Order | - | ✅ | - | - | HIGH | PUSH, IN_APP | 1 |
| 25 | Admin | Payment Issue | - | ✅ | - | - | CRITICAL | PUSH, IN_APP, EMAIL | 2 |
| 26 | Admin | Low Inventory | - | ✅ | - | - | MEDIUM | PUSH, IN_APP | 3 |
| 27 | Admin | High Rewards | - | ✅ | - | - | LOW | IN_APP | 3 |

**Total: 27 notifications critiques**

---

## ✅ À NE PAS FAIRE

### Notifications Inutiles à Éviter

```
❌ "Bienvenue sur Alpha!"
   Pas actionnelle, marketing noise

❌ "Points gagnés: 150 pts" (après chaque commande)
   Client le voit dans dashboard, redondant

❌ "Vous avez 5000 points disponibles"
   Information statique, pas changement

❌ Notif toutes les heures
   Agaçant, user desactivera notifications

❌ "Livraison en route" + "5 minutes" + "3 minutes"
   Trop fréquent, merge en une

❌ "Cliquez ici pour voir votre commande"
   Pas de valeur ajoutée

❌ Notifications pendant quiet hours (22h-8h)
   Déranger le sommeil client
```

### Bonnes Pratiques

```
✅ Une notification = une action ou un changement important
✅ Tailler les messages (court & direct)
✅ Toujours inclure un lien d'action
✅ Respecter quiet hours
✅ Permettre opt-out pour non-critiques
✅ Batch les mises à jour (pas 10 notifs pour 1 commande)
✅ Test notifications avant lancement
✅ Monitor delivery rate et engagement
```

---

## 📱 Implémentation Frontend

### Réception des Notifications (Flutter)

```dart
// lib/services/notification_service.dart

class NotificationService {
  
  static Future<void> initializeNotifications() async {
    // Firebase Cloud Messaging setup
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Handle notification tap
    messaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data);
    });
    
    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showInAppNotification(message);
    });
  }
  
  static void handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    final params = jsonDecode(data['params']);
    
    // Route based on notification type
    switch(type) {
      case 'REWARD_CLAIM_APPROVED':
        navigateTo('/rewards/${params['rewardId']}');
        break;
      case 'ORDER_READY_PICKUP':
        navigateTo('/orders/${params['orderId']}');
        break;
      // ... other types
    }
  }
  
  static void showInAppNotification(RemoteMessage message) {
    Get.snackbar(
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      duration: Duration(seconds: 4)
    );
  }
}
```

---

**Rédigé par:** Assistant d'analyse système  
**Dernier update:** 16 Octobre 2025  
**Prochaine review:** Après implémentation Phase 1



| # | Feature | Type | Client | Admin | Delivery | Affiliate | Priority | Channels | Phase |
|---|---------|------|--------|-------|----------|-----------|----------|----------|-------|
| 1 | Loyalty | Reward Approved | ✅ | - | - | - | HIGH | PUSH, IN_APP | 1 |
| 2 | Loyalty | Reward Rejected | ✅ | - | - | - | HIGH | PUSH, IN_APP, EMAIL | 1 |
| 3 | Loyalty | Points Milestone | ✅ | - | - | - | LOW | PUSH | 3 |
| 4 | Loyalty | Reward Used | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP | 2 |

| 6 | Orders | Order Placed | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP, EMAIL | 1 |
| 7 | Orders | Payment Failed | ✅ | ✅ | - | - | CRITICAL | PUSH, IN_APP, EMAIL | 1 |
| 8 | Orders | Status Changed | ✅ | ✅ | ✅ | - | HIGH | PUSH, IN_APP | 1 |
| 9 | Orders | Ready Pickup | ✅ | - | - | - | HIGH | PUSH, EMAIL | 1 |
| 10 | Orders | Reminder | ✅ | - | - | - | LOW | PUSH | 3 |
| 11 | Orders | Cancelled | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP, EMAIL | 1 |

| 14 | Delivery | Completed | ✅ | ✅ | - | - | HIGH | PUSH, IN_APP | 1 |
| 15 | Delivery | Problem | ✅ | ✅ | ✅ | - | CRITICAL | PUSH, IN_APP | 1 |
| 16 | Affiliate | Referral Used | - | - | - | ✅ | HIGH | PUSH, IN_APP | 2 |
| 17 | Affiliate | Commission Earned | - | - | - | ✅ | HIGH | PUSH, IN_APP | 2 |
| 18 | Affiliate | Withdrawal Approved | - | - | - | ✅ | HIGH | PUSH, IN_APP, EMAIL | 2 |
| 19 | Affiliate | Withdrawal Rejected | - | - | - | ✅ | HIGH | PUSH, IN_APP | 2 |
| 20 | Affiliate | Level Up | - | - | - | ✅ | MEDIUM | PUSH, IN_APP | 3 |

| 24 | Admin | New Order | - | ✅ | - | - | HIGH | PUSH, IN_APP | 1 |
| 25 | Admin | Payment Issue | - | ✅ | - | - | CRITICAL | PUSH, IN_APP, EMAIL | 2 |
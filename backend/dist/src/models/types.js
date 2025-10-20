"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentStatus = exports.PaymentMethod = exports.ServiceFromJson = exports.NotificationType = void 0;
// Notification related types
var NotificationType;
(function (NotificationType) {
    NotificationType["ORDER_STATUS"] = "ORDER_STATUS";
    NotificationType["ORDER_CREATED"] = "ORDER_CREATED";
    NotificationType["ORDER_STATUS_UPDATED"] = "ORDER_STATUS_UPDATED";
    NotificationType["SERVICE_ADDED"] = "SERVICE_ADDED";
    NotificationType["SERVICE_CREATED"] = "SERVICE_CREATED";
    NotificationType["SERVICE_UPDATED"] = "SERVICE_UPDATED";
    NotificationType["SERVICE_TYPE_CREATED"] = "SERVICE_TYPE_CREATED";
    NotificationType["SERVICE_TYPE_UPDATED"] = "SERVICE_TYPE_UPDATED";
    NotificationType["WEIGHT_RECORDED"] = "WEIGHT_RECORDED";
    NotificationType["SUBSCRIPTION_CREATED"] = "SUBSCRIPTION_CREATED";
    NotificationType["SUBSCRIPTION_CANCELLED"] = "SUBSCRIPTION_CANCELLED";
    NotificationType["AFFILIATE_STATUS_UPDATED"] = "AFFILIATE_STATUS_UPDATED";
    NotificationType["POINTS_EARNED"] = "POINTS_EARNED";
    NotificationType["REFERRAL_BONUS"] = "REFERRAL_BONUS";
    NotificationType["PROMOTIONS"] = "PROMOTIONS";
    NotificationType["PRICE_UPDATED"] = "PRICE_UPDATED";
    NotificationType["OFFER_CREATED"] = "OFFER_CREATED";
    NotificationType["OFFER_UPDATED"] = "OFFER_UPDATED";
    NotificationType["OFFER_DELETED"] = "OFFER_DELETED";
    NotificationType["OFFER_SUBSCRIBED"] = "OFFER_SUBSCRIBED";
    NotificationType["OFFER_UNSUBSCRIBED"] = "OFFER_UNSUBSCRIBED";
    NotificationType["ARTICLE_CREATED"] = "ARTICLE_CREATED";
    // Ajout des nouveaux types
    NotificationType["WITHDRAWAL_REQUESTED"] = "WITHDRAWAL_REQUESTED";
    NotificationType["WITHDRAWAL_PROCESSED"] = "WITHDRAWAL_PROCESSED";
    NotificationType["WITHDRAWAL_REJECTED"] = "WITHDRAWAL_REJECTED";
    NotificationType["COMMISSION_EARNED"] = "COMMISSION_EARNED";
})(NotificationType || (exports.NotificationType = NotificationType = {}));
// Ajout de la fonction fromJson comme une fonction utilitaire séparée
const ServiceFromJson = (json) => {
    return {
        id: json.id,
        name: json.name,
        price: json.price,
        description: json.description,
        createdAt: new Date(json.createdAt),
        updatedAt: new Date(json.updatedAt),
        service_type_id: json.service_type_id,
    };
};
exports.ServiceFromJson = ServiceFromJson;
var PaymentMethod;
(function (PaymentMethod) {
    PaymentMethod["CASH"] = "CASH";
    PaymentMethod["ORANGE_MONEY"] = "ORANGE_MONEY";
})(PaymentMethod || (exports.PaymentMethod = PaymentMethod = {}));
var PaymentStatus;
(function (PaymentStatus) {
    PaymentStatus["PENDING"] = "PENDING";
    PaymentStatus["PAID"] = "PAID";
    PaymentStatus["FAILED"] = "FAILED";
    PaymentStatus["REFUNDED"] = "REFUNDED";
})(PaymentStatus || (exports.PaymentStatus = PaymentStatus = {}));

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationType = void 0;
var NotificationType;
(function (NotificationType) {
    // Order related
    NotificationType["NEW_ORDER"] = "new_order";
    NotificationType["ORDER_STATUS_UPDATE"] = "order_status_update";
    NotificationType["ORDER_COMPLETED"] = "order_completed";
    // Affiliate related
    NotificationType["NEW_REFERRAL"] = "new_referral";
    NotificationType["COMMISSION_EARNED"] = "commission_earned";
    NotificationType["SUB_AFFILIATE_ACTIVITY"] = "sub_affiliate_activity";
    NotificationType["AFFILIATE_PERFORMANCE"] = "affiliate_performance";
    NotificationType["WITHDRAWAL_REQUEST"] = "withdrawal_request";
    NotificationType["WITHDRAWAL_PROCESSED"] = "withdrawal_processed";
    // Customer related
    NotificationType["LOYALTY_POINTS_REMINDER"] = "loyalty_points_reminder";
    NotificationType["SAVINGS_ALERT"] = "savings_alert";
    NotificationType["PROMOTION_AVAILABLE"] = "promotion_available";
    // Admin broadcasts
    NotificationType["SERVICE_UPDATE"] = "service_update";
    NotificationType["GENERAL_ANNOUNCEMENT"] = "general_announcement";
})(NotificationType || (exports.NotificationType = NotificationType = {}));

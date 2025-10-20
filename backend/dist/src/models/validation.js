"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateOrderData = validateOrderData;
exports.sanitizeOrderDataForLogs = sanitizeOrderDataForLogs;
const types_1 = require("./types");
function validateOrderData(data) {
    console.log('[Validation] Starting order data validation');
    const validation = {
        userId: typeof data.userId === 'string',
        serviceId: typeof data.serviceId === 'string',
        serviceTypeId: typeof data.serviceTypeId === 'string' || typeof data.service_type_id === 'string',
        addressId: typeof data.addressId === 'string',
        items: Array.isArray(data.items),
        paymentMethod: Object.values(types_1.PaymentMethod).includes(data.paymentMethod)
    };
    console.log('[Validation] Validation results:', Object.assign(Object.assign({}, validation), { receivedTypes: {
            userId: typeof data.userId,
            serviceId: typeof data.serviceId,
            serviceTypeId: typeof data.serviceTypeId,
            service_type_id: typeof data.service_type_id,
            addressId: typeof data.addressId,
            items: Array.isArray(data.items) ? `Array[${data.items.length}]` : typeof data.items
        } }));
    const isValid = Object.values(validation).every(v => v);
    console.log('[Validation] Final result:', isValid);
    return isValid;
}
// Fonction utilitaire pour masquer les données sensibles dans les logs
function sanitizeOrderDataForLogs(data) {
    return Object.assign(Object.assign({}, data), { userId: data.userId ? '***' : undefined, paymentInfo: data.paymentInfo ? '***' : undefined });
}

import { CreateOrderDTO, PaymentMethod } from './types';

export function validateOrderData(data: any): data is CreateOrderDTO {
  console.log('[Validation] Starting order data validation');
  
  const validation = {
    userId: typeof data.userId === 'string',
    serviceId: typeof data.serviceId === 'string',
    serviceTypeId: typeof data.serviceTypeId === 'string' || typeof data.service_type_id === 'string',
    addressId: typeof data.addressId === 'string',
    items: Array.isArray(data.items),
    paymentMethod: Object.values(PaymentMethod).includes(data.paymentMethod as PaymentMethod)
  };

  console.log('[Validation] Validation results:', {
    ...validation,
    receivedTypes: {
      userId: typeof data.userId,
      serviceId: typeof data.serviceId,
      serviceTypeId: typeof data.serviceTypeId,
      service_type_id: typeof data.service_type_id,
      addressId: typeof data.addressId,
      items: Array.isArray(data.items) ? `Array[${data.items.length}]` : typeof data.items
    }
  });

  const isValid = Object.values(validation).every(v => v);
  console.log('[Validation] Final result:', isValid);

  return isValid;
}

// Fonction utilitaire pour masquer les données sensibles dans les logs
export function sanitizeOrderDataForLogs(data: any) {
  return {
    ...data,
    userId: data.userId ? '***' : undefined,
    paymentInfo: data.paymentInfo ? '***' : undefined,
  };
}

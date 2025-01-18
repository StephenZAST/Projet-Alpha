export type DeliveryOrderStatus = 
  | 'PENDING'
  | 'COLLECTING'
  | 'COLLECTED'
  | 'PROCESSING'
  | 'READY'
  | 'DELIVERING'
  | 'DELIVERED'
  | 'CANCELLED';

export interface DeliveryOrder {
  id: string;
  userId: string;
  status: DeliveryOrderStatus;
  customerName: string;
  address: {
    street: string;
    city: string;
    postal_code: string;
  };
  collectionDate?: string;
  deliveryDate?: string;
  totalAmount: number;
  createdAt: string;
  updatedAt: string;
}

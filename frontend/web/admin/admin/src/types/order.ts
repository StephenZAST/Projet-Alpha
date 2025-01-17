export type OrderStatus = 'PENDING' | 'PROCESSING' | 'COMPLETED' | 'CANCELLED' | 'DELIVERING' | 'DELIVERED';

export interface Order {
  id: string;
  customerName: string;
  amount: number;
  status: OrderStatus;
  items: OrderItem[];
  createdAt: string;
  address?: string;
  paymentStatus: 'PENDING' | 'COMPLETED';
  paymentMethod: string;
}

export interface OrderItem {
  id: string;
  productName: string;
  quantity: number;
  price: number;
  serviceType?: string;
}

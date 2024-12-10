import { UserProfile } from './user';
import { Timestamp } from 'firebase/firestore'

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PROCESSING = 'processing',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
}

export enum PaymentMethod {
  CREDIT_CARD = 'credit_card',
  CASH_ON_DELIVERY = 'cash_on_delivery',
  PAYPAL = 'paypal',
  APPLE_PAY = 'apple_pay',
  GOOGLE_PAY = 'google_pay',
}

export enum OrderType {
  NORMAL = 'normal',
  ONE_CLICK = 'one-click',
}

export interface OrderItem {
  productId: string;
  name: string;
  quantity: number;
  price: number;
  imageUrl: string;
}

export interface DeliveryDetails {
  address: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  phoneNumber: string;
  zoneId: string;
}

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  specialInstructions: string;
  totalPrice: number;
  status: OrderStatus;
  paymentMethod: PaymentMethod;
  deliveryDetails: DeliveryDetails;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  orderType: OrderType;
  scheduledDeliveryTime?: Timestamp;
  oneClickOrder?: boolean;
  userProfile: UserProfile;
  deliveryFee: number;
}

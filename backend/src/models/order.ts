import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
  ACCEPTED = 'accepted',
  PICKED_UP = 'picked_up',
  DELIVERING = 'delivering',
  COMPLETED = 'completed'
}

export enum OrderType {
  STANDARD = 'standard',
  ONE_CLICK = 'one_click'
}

export enum MainService {
  LAUNDRY = 'laundry',
  DRY_CLEANING = 'dry_cleaning',
  IRONING = 'ironing',
  WASH_AND_IRON = 'wash_and_iron',
  WASH_ONLY = 'wash_only',
  IRON_ONLY = 'iron_only',
  PICKUP_DELIVERY = 'pickup_delivery',
  REPASSAGE = 'repassage',
  NETTOYAGE_SEC = 'nettoyage_sec',
  BLANCHISSERIE = 'blanchisserie'
}

export enum AdditionalService {
  EXPRESS_DELIVERY = 'express_delivery',
  SAME_DAY_DELIVERY = 'same_day_delivery',
  HAND_IRONING = 'hand_ironing',
  STEAM_CLEANING = 'steam_cleaning',
  DRYING = 'drying',
  FOLDING = 'folding',
  BAGGING = 'bagging'
}

export enum ArticleCategory {
  CLOTHING = 'clothing',
  LINENS = 'linens',
  ACCESSORIES = 'accessories',
  OTHER = 'other'
}

export enum PaymentMethod {
  CASH = 'cash',
  CARD = 'card',
  MOBILE_MONEY = 'mobile_money',
  BANK_TRANSFER = 'bank_transfer'
}

export enum PriceType {
  FIXED = 'fixed',
  PER_UNIT = 'per_unit'
}

export interface OrderItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  itemType: string;
  priceType: PriceType;
}

export interface OrderInput {
  userId: string;
  items: OrderItem[];
  totalAmount: number;
  paymentMethod: PaymentMethod;
  type?: OrderType;
  oneClickOrder?: boolean;
  orderNotes?: string;
}

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  totalAmount: number;
  status: OrderStatus;
  type: OrderType;
  createdAt: string;
  updatedAt: string;
  deliveryAddress: string;
  deliveryInstructions: string;
  deliveryPersonId: string | null;
  deliveryTime: string | null;
  paymentMethod: PaymentMethod;
  paymentStatus: 'PENDING' | 'PAID' | 'FAILED' | 'REFUNDED';
  loyaltyPointsUsed: number;
  loyaltyPointsEarned: number;
  referralCode: string | null;
  oneClickOrder: boolean;
  orderNotes: string;
  pickupLocation: {
    latitude: number;
    longitude: number;
  };
  deliveryLocation: {
    latitude: number;
    longitude: number;
  };
  scheduledPickupTime: string;
  scheduledDeliveryTime: string;
  completionDate: string | null;
  creationDate: string;
  pickedUpAt?: string;
  deliveredAt?: string;
}

export interface RouteStop {
  type: 'pickup' | 'delivery';
  location: {
    latitude: number;
    longitude: number;
  };
  orderId: string;
  scheduledTime: Date;
  address: string;
}

export interface GetOrdersOptions {
  page?: number;
  limit?: number;
  status?: OrderStatus;
  userId?: string;
  startDate?: Date;
  endDate?: Date;
}

export interface OrderStatistics {
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  totalOrdersDelivered: number;
}

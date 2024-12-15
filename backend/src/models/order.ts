import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled'
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
}

// Use Supabase to store order data
const ordersTable = 'orders';

// Function to get order data
export async function getOrder(id: string): Promise<Order | null> {
  const { data, error } = await supabase.from(ordersTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch order', 'INTERNAL_SERVER_ERROR');
  }

  return data as Order;
}

// Function to create order
export async function createOrder(orderData: Order): Promise<Order> {
  const { data, error } = await supabase.from(ordersTable).insert([orderData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create order', 'INTERNAL_SERVER_ERROR');
  }

  return data as Order;
}

// Function to update order
export async function updateOrder(id: string, orderData: Partial<Order>): Promise<Order> {
  const currentOrder = await getOrder(id);

  if (!currentOrder) {
    throw new AppError(404, 'Order not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(ordersTable).update(orderData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update order', 'INTERNAL_SERVER_ERROR');
  }

  return data as Order;
}

// Function to delete order
export async function deleteOrder(id: string): Promise<void> {
  const order = await getOrder(id);

  if (!order) {
    throw new AppError(404, 'Order not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(ordersTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete order', 'INTERNAL_SERVER_ERROR');
  }
}

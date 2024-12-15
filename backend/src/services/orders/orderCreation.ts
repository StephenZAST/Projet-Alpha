import { createClient } from '@supabase/supabase-js';
import { Order, OrderStatus, OrderType, OrderItem, OrderInput, PaymentMethod } from '../../models/order';
import { UserProfile, UserAddress } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { getUserProfile } from '../users/userRetrieval';
import { checkDeliverySlotAvailability } from '../delivery';
import { validateOrderData } from '../../validation/orders';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const ordersTable = 'orders';

/**
 * Create a new order
 */
export async function createOrder(orderData: OrderInput): Promise<Order> {
  try {
    const now = new Date().toISOString();

    const userProfile = await getUserProfile(orderData.userId);
    if (!userProfile) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const newOrder: Order = {
      id: undefined,
      userId: orderData.userId,
      items: orderData.items,
      totalAmount: orderData.totalAmount,
      status: OrderStatus.PENDING,
      type: orderData.type || OrderType.STANDARD,
      createdAt: now,
      updatedAt: now,
      deliveryAddress: userProfile.address ? JSON.stringify(userProfile.address) : '',
      deliveryInstructions: userProfile.defaultInstructions || '',
      deliveryPersonId: null,
      deliveryTime: null,
      paymentMethod: orderData.paymentMethod || PaymentMethod.CASH,
      paymentStatus: 'PENDING',
      loyaltyPointsUsed: 0,
      loyaltyPointsEarned: 0,
      referralCode: null,
      oneClickOrder: orderData.oneClickOrder || false,
      orderNotes: orderData.orderNotes || ''
    };

    const { data, error } = await supabase.from(ordersTable).insert([newOrder]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create order', errorCodes.DATABASE_ERROR);
    }

    return { id: data.id, ...newOrder };
  } catch (error) {
    console.error('Error creating order:', error);
    throw error;
  }
}

/**
 * Create a one-click order
 */
export async function createOneClickOrder(orderData: OrderInput & { zoneId: string }): Promise<Order> {
  try {
    const now = new Date().toISOString();

    const userProfile = await getUserProfile(orderData.userId);
    if (!userProfile) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const deliverySlotAvailable = await checkDeliverySlotAvailability(orderData.zoneId, new Date());

    if (!deliverySlotAvailable) {
      throw new AppError(400, 'No available delivery slot', errorCodes.INVALID_DELIVERY_DATA);
    }

    const newOrder: Order = {
      id: undefined,
      userId: orderData.userId,
      items: userProfile.defaultItems || [],
      totalAmount: 0, // Calculate total amount based on default items
      status: OrderStatus.PENDING,
      type: OrderType.ONE_CLICK,
      createdAt: now,
      updatedAt: now,
      deliveryAddress: userProfile.address ? JSON.stringify(userProfile.address) : '',
      deliveryInstructions: userProfile.defaultInstructions || '',
      deliveryPersonId: null,
      deliveryTime: null,
      paymentMethod: PaymentMethod.CASH,
      paymentStatus: 'PENDING',
      loyaltyPointsUsed: 0,
      loyaltyPointsEarned: 0,
      referralCode: null,
      oneClickOrder: true,
      orderNotes: ''
    };

    // Calculate total amount based on default items
    newOrder.totalAmount = newOrder.items.reduce((total: number, item: OrderItem) => total + item.price * item.quantity, 0);

    const { data, error } = await supabase.from(ordersTable).insert([newOrder]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create one-click order', errorCodes.DATABASE_ERROR);
    }

    return { id: data.id, ...newOrder };
  } catch (error) {
    console.error('Error creating one-click order:', error);
    throw error;
  }
}

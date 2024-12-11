import { db, auth, CollectionReference, Timestamp } from '../../config/firebase';
import { Order, OrderStatus, OrderType, OrderItem, OrderInput } from '../../models/order';
import { UserProfile, UserAddress } from '../../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../../utils/tokens';
import { sendVerificationEmail } from '../users/userVerification';
import { AppError, errorCodes } from '../../utils/errors';
import { getUserProfile } from '../users/userRetrieval';

const ORDERS_COLLECTION = 'orders';

export async function createOrder(orderData: OrderInput): Promise<Order> {
  try {
    const orderRef = db.collection(ORDERS_COLLECTION).doc();
    const now = Timestamp.now();

    const userProfile = await getUserProfile(orderData.userId);
    if (!userProfile) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const newOrder: Order = {
      id: orderRef.id,
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
      paymentMethod: orderData.paymentMethod,
      paymentStatus: 'PENDING',
      loyaltyPointsUsed: 0,
      loyaltyPointsEarned: 0,
      referralCode: null,
      oneClickOrder: orderData.oneClickOrder || false,
      orderNotes: orderData.orderNotes || ''
    };

    await orderRef.set(newOrder);

    return newOrder;
  } catch (error) {
    console.error('Error creating order:', error);
    throw error;
  }
}

export async function createOneClickOrder(orderData: OrderInput): Promise<Order> {
  try {
    const orderRef = db.collection(ORDERS_COLLECTION).doc();
    const now = Timestamp.now();

    const userProfile = await getUserProfile(orderData.userId);
    if (!userProfile) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const newOrder: Order = {
      id: orderRef.id,
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
      paymentMethod: 'CASH',
      paymentStatus: 'PENDING',
      loyaltyPointsUsed: 0,
      loyaltyPointsEarned: 0,
      referralCode: null,
      oneClickOrder: true,
      orderNotes: ''
    };

    // Calculate total amount based on default items
    newOrder.totalAmount = newOrder.items.reduce((total: number, item: OrderItem) => total + item.price * item.quantity, 0);

    await orderRef.set(newOrder);

    return newOrder;
  } catch (error) {
    console.error('Error creating one-click order:', error);
    throw error;
  }
}

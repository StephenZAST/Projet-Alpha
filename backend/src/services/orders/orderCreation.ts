import { db, admin } from '../../config/firebase';
import { Order, OrderStatus, PaymentMethod, OrderItem, DeliveryDetails, OrderType } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { calculateDistance, haversineDistance } from '../../utils/location';
import { User, UserProfile } from '../../models/user';
import { getUserProfile } from '../users';
import { getZoneById } from '../zones';

const ordersRef = db.collection('orders');

export const createOrder = async (
  userId: string,
  items: OrderItem[],
  specialInstructions: string,
  paymentMethod: PaymentMethod,
  deliveryDetails: DeliveryDetails,
  orderType: OrderType,
  scheduledDeliveryTime?: admin.firestore.Timestamp,
  oneClickOrder?: boolean
): Promise<Order> => {
  try {
    const userProfile = await getUserProfile(userId);
    if (!userProfile) {
      throw new AppError(400, 'User not found.', errorCodes.USER_NOT_FOUND);
    }

    const userAddress = userProfile.address;
    if (!userAddress) {
      throw new AppError(400, 'User address not found.', errorCodes.USER_ADDRESS_NOT_FOUND);
    }

    const zone = await getZoneById(deliveryDetails.zoneId);
    if (!zone) {
      throw new AppError(400, 'Invalid zone ID.', errorCodes.INVALID_ZONE);
    }

    const deliveryFee = zone.deliveryFee;

    const totalPrice = items.reduce((sum, item) => sum + (item.price * item.quantity), 0) + deliveryFee;

    const newOrder: Order = {
      id: '',
      userId,
      items,
      specialInstructions,
      totalPrice,
      status: OrderStatus.PENDING,
      paymentMethod,
      deliveryDetails,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      orderType,
      scheduledDeliveryTime,
      oneClickOrder: oneClickOrder || false,
      userProfile: userProfile,
      deliveryFee: deliveryFee
    };

    const orderRef = await ordersRef.add(newOrder);
    newOrder.id = orderRef.id;

    await orderRef.update({ id: newOrder.id });

    return newOrder;
  } catch (error) {
    console.error('Error creating order:', error);
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to create order.', errorCodes.ORDER_CREATION_FAILED);
  }
};

export const createOneClickOrder = async (
  userId: string,
  paymentMethod: PaymentMethod,
  deliveryDetails: DeliveryDetails
): Promise<Order> => {
  try {
    const userProfile = await getUserProfile(userId);
    if (!userProfile) {
      throw new AppError(400, 'User not found.', errorCodes.USER_NOT_FOUND);
    }

    if (!userProfile.defaultItems || userProfile.defaultItems.length === 0) {
      throw new AppError(400, 'No default items found for one-click order.', errorCodes.NO_DEFAULT_ITEMS);
    }

    const items = userProfile.defaultItems;
    const specialInstructions = userProfile.defaultInstructions || '';

    return createOrder(userId, items, specialInstructions, paymentMethod, deliveryDetails, OrderType.ONE_CLICK, undefined, true);
  } catch (error) {
    console.error('Error creating one-click order:', error);
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to create one-click order.', errorCodes.ONE_CLICK_ORDER_FAILED);
  }
};

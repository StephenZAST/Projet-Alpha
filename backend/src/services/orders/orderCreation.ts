import { Timestamp, GeoPoint } from 'firebase-admin/firestore';
import { Order, OrderStatus, OrderType, Location, OrderItem, MainService, PriceType, ItemType } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { getUserProfile } from '../users';
import { validateOrderData } from '../../validation/orders';
import { checkDeliverySlotAvailability } from '../delivery';
import { Address, User } from '../../models/user';
import { db } from '../firebase'; // Import db

export async function createOrder(orderData: Partial<Order>): Promise<Order> {
  try {
    // Valider les données d'entrée
    const validationResult = validateOrderData(orderData);
    if (!validationResult.isValid) {
      throw new AppError(400, validationResult.errors.join(', '), errorCodes.INVALID_ORDER_DATA);
    }

    // Vérifier la disponibilité du créneau
    const isSlotAvailable = await checkDeliverySlotAvailability(
      orderData.zoneId!,
      orderData.scheduledPickupTime!,
      orderData.scheduledDeliveryTime!
    );
    if (!isSlotAvailable) {
      throw new AppError(400, 'Selected delivery slot is not available', errorCodes.SLOT_NOT_AVAILABLE);
    }

    // S'assurer que tous les champs requis sont présents
    if (!orderData.userId || !orderData.type || !orderData.items || !orderData.zoneId) {
      throw new AppError(400, 'Missing required fields', errorCodes.INVALID_ORDER_DATA);
    }

    const order: Order = {
      userId: orderData.userId,
      type: orderData.type,
      items: orderData.items,
      status: OrderStatus.PENDING,
      pickupAddress: orderData.pickupAddress!,
      pickupLocation: orderData.pickupLocation!,
      deliveryAddress: orderData.deliveryAddress!,
      deliveryLocation: orderData.deliveryLocation!,
      scheduledPickupTime: orderData.scheduledPickupTime!,
      scheduledDeliveryTime: orderData.scheduledDeliveryTime!,
      creationDate: Timestamp.now(),
      updatedAt: Timestamp.now(),
      totalAmount: orderData.totalAmount!,
      zoneId: orderData.zoneId,
      serviceType: orderData.serviceType!
    };

    const orderRef = await db.collection('orders').add(order);
    return { ...order, id: orderRef.id };
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error creating order:', error);
    throw new AppError(500, 'Failed to create order', errorCodes.ORDER_CREATION_FAILED);
  }
}

export async function createOneClickOrder(
  userId: string,
  zoneId: string
): Promise<Order> {
  try {
    const userProfile = await getUserProfile(userId) as User;
    if (!userProfile || !userProfile.profile.address) {
      throw new AppError(404, 'User profile or default address not found', errorCodes.INVALID_USER_PROFILE);
    }

    const defaultAddress = userProfile.profile.address as Address;
    if (!defaultAddress.coordinates) {
      throw new AppError(400, 'Default address coordinates not found', errorCodes.INVALID_ADDRESS_DATA);
    }
    const order: Partial<Order> = {
      userId,
      type: OrderType.ONE_CLICK,
      zoneId,
      status: OrderStatus.PENDING,
      pickupAddress: defaultAddress.street, // Use defaultAddress.street
      pickupLocation: {
        latitude: defaultAddress.coordinates.latitude,
        longitude: defaultAddress.coordinates.longitude
      },
      scheduledPickupTime: Timestamp.fromDate(new Date(Date.now() + 3600000)), // +1h
      scheduledDeliveryTime: Timestamp.fromDate(new Date(Date.now() + 7200000)), // +2h
      items: (userProfile.defaultItems || []).map(item => ({
        id: item.id,
        quantity: item.quantity,
        itemType: ItemType.PRODUCT, // Use ItemType enum
        mainService: MainService.PRESSING, // Provide a default MainService value
        price: 0, // Provide a default value or handle this based on your logic
        priceType: PriceType.FIXED // Provide a default PriceType value
      })),
      specialInstructions: userProfile.defaultInstructions
    };

    return await createOrder(order);
  } catch (error) {
    console.error('Error creating one-click order:', error);
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to create one-click order', errorCodes.ONE_CLICK_ORDER_FAILED);
  }
}

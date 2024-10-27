import { db } from './firebase';
import { AppError, errorCodes } from '../utils/errors';

export interface Subscription {
  id: string;
  name: string;
  price: number;
  weightLimitPerWeek: number;
  description: string;
  features: string[];
  isActive: boolean;
}

export interface UserSubscription {
  id: string;
  userId: string;
  subscriptionId: string;
  startDate: Date;
  endDate: Date;
  status: 'active' | 'cancelled' | 'expired';
}

export async function getSubscriptions(): Promise<Subscription[]> {
  try {
    const subscriptionsSnapshot = await db.collection('subscriptions').get();
    return subscriptionsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Subscription));
  } catch (error) {
    throw new AppError(500, 'Failed to fetch subscriptions', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscription(subscriptionData: Omit<Subscription, 'id'>): Promise<Subscription> {
  try {
    const subscriptionRef = await db.collection('subscriptions').add(subscriptionData);
    return { ...subscriptionData, id: subscriptionRef.id };
  } catch (error) {
    throw new AppError(500, 'Failed to create subscription', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscription(subscriptionId: string, subscriptionData: Partial<Subscription>): Promise<Subscription> {
  try {
    const subscriptionRef = db.collection('subscriptions').doc(subscriptionId);
    await subscriptionRef.update(subscriptionData);
    const updatedSubscription = await subscriptionRef.get();
    return { id: subscriptionId, ...updatedSubscription.data() } as Subscription;
  } catch (error) {
    throw new AppError(500, 'Failed to update subscription', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscription(subscriptionId: string): Promise<void> {
  try {
    await db.collection('subscriptions').doc(subscriptionId).delete();
  } catch (error) {
    throw new AppError(500, 'Failed to delete subscription', errorCodes.DATABASE_ERROR);
  }
}

export async function getUserSubscription(userId: string): Promise<UserSubscription | null> {
  try {
    const userSubSnapshot = await db.collection('userSubscriptions')
      .where('userId', '==', userId)
      .where('status', '==', 'active')
      .get();
    
    if (userSubSnapshot.empty) return null;
    
    return {
      id: userSubSnapshot.docs[0].id,
      ...userSubSnapshot.docs[0].data()
    } as UserSubscription;
  } catch (error) {
    throw new AppError(500, 'Failed to fetch user subscription', errorCodes.DATABASE_ERROR);
  }
}

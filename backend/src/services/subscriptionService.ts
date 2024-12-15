import { Subscription, SubscriptionStatus, SubscriptionType, SubscriptionPlan, SubscriptionPause, SubscriptionBilling, SubscriptionUsage, SubscriptionNotification, SubscriptionUsageSnapshot } from '../models/subscription';
import { AppError, errorCodes } from '../utils/errors';
import { getSubscription, createSubscription, updateSubscription, deleteSubscription } from './subscriptionService/subscriptionManagement';
import { getSubscriptionPlan, createSubscriptionPlan, updateSubscriptionPlan, deleteSubscriptionPlan } from './subscriptionService/subscriptionPlanManagement';
import { getSubscriptionPause, createSubscriptionPause, updateSubscriptionPause, deleteSubscriptionPause } from './subscriptionService/subscriptionPauseManagement';
import { getSubscriptionBilling, createSubscriptionBilling, updateSubscriptionBilling, deleteSubscriptionBilling } from './subscriptionService/subscriptionBillingManagement';
import { getSubscriptionUsage, createSubscriptionUsage, updateSubscriptionUsage, deleteSubscriptionUsage } from './subscriptionService/subscriptionUsage';
import { getSubscriptionNotification, createSubscriptionNotification, updateSubscriptionNotification, deleteSubscriptionNotification } from './subscriptionService/subscriptionNotification';
import { getSubscriptionUsageSnapshot, createSubscriptionUsageSnapshot, updateSubscriptionUsageSnapshot, deleteSubscriptionUsageSnapshot } from './subscriptionService/subscriptionUsageSnapshot';

export class SubscriptionService {
  async getSubscription(id: string): Promise<Subscription | null> {
    return getSubscription(id);
  }

  async createSubscription(subscriptionData: Subscription): Promise<Subscription> {
    return createSubscription(subscriptionData);
  }

  async updateSubscription(id: string, subscriptionData: Partial<Subscription>): Promise<Subscription> {
    return updateSubscription(id, subscriptionData);
  }

  async deleteSubscription(id: string): Promise<void> {
    return deleteSubscription(id);
  }

  async getSubscriptionPlan(id: string): Promise<SubscriptionPlan | null> {
    return getSubscriptionPlan(id);
  }

  async createSubscriptionPlan(planData: SubscriptionPlan): Promise<SubscriptionPlan> {
    return createSubscriptionPlan(planData);
  }

  async updateSubscriptionPlan(id: string, planData: Partial<SubscriptionPlan>): Promise<SubscriptionPlan> {
    return updateSubscriptionPlan(id, planData);
  }

  async deleteSubscriptionPlan(id: string): Promise<void> {
    return deleteSubscriptionPlan(id);
  }

  async getSubscriptionPause(id: string): Promise<SubscriptionPause | null> {
    return getSubscriptionPause(id);
  }

  async createSubscriptionPause(pauseData: SubscriptionPause): Promise<SubscriptionPause> {
    return createSubscriptionPause(pauseData);
  }

  async updateSubscriptionPause(id: string, pauseData: Partial<SubscriptionPause>): Promise<SubscriptionPause> {
    return updateSubscriptionPause(id, pauseData);
  }

  async deleteSubscriptionPause(id: string): Promise<void> {
    return deleteSubscriptionPause(id);
  }

  async getSubscriptionBilling(id: string): Promise<SubscriptionBilling | null> {
    return getSubscriptionBilling(id);
  }

  async createSubscriptionBilling(billingData: SubscriptionBilling): Promise<SubscriptionBilling> {
    return createSubscriptionBilling(billingData);
  }

  async updateSubscriptionBilling(id: string, billingData: Partial<SubscriptionBilling>): Promise<SubscriptionBilling> {
    return updateSubscriptionBilling(id, billingData);
  }

  async deleteSubscriptionBilling(id: string): Promise<void> {
    return deleteSubscriptionBilling(id);
  }

  async getSubscriptionUsage(id: string): Promise<SubscriptionUsage | null> {
    return getSubscriptionUsage(id);
  }

  async createSubscriptionUsage(usageData: SubscriptionUsage): Promise<SubscriptionUsage> {
    return createSubscriptionUsage(usageData);
  }

  async updateSubscriptionUsage(id: string, usageData: Partial<SubscriptionUsage>): Promise<SubscriptionUsage> {
    return updateSubscriptionUsage(id, usageData);
  }

  async deleteSubscriptionUsage(id: string): Promise<void> {
    return deleteSubscriptionUsage(id);
  }

  async getSubscriptionNotification(id: string): Promise<SubscriptionNotification | null> {
    return getSubscriptionNotification(id);
  }

  async createSubscriptionNotification(notificationData: SubscriptionNotification): Promise<SubscriptionNotification> {
    return createSubscriptionNotification(notificationData);
  }

  async updateSubscriptionNotification(id: string, notificationData: Partial<SubscriptionNotification>): Promise<SubscriptionNotification> {
    return updateSubscriptionNotification(id, notificationData);
  }

  async deleteSubscriptionNotification(id: string): Promise<void> {
    return deleteSubscriptionNotification(id);
  }

  async getSubscriptionUsageSnapshot(id: string): Promise<SubscriptionUsageSnapshot | null> {
    return getSubscriptionUsageSnapshot(id);
  }

  async createSubscriptionUsageSnapshot(snapshotData: SubscriptionUsageSnapshot): Promise<SubscriptionUsageSnapshot> {
    return createSubscriptionUsageSnapshot(snapshotData);
  }

  async updateSubscriptionUsageSnapshot(id: string, snapshotData: Partial<SubscriptionUsageSnapshot>): Promise<SubscriptionUsageSnapshot> {
    return updateSubscriptionUsageSnapshot(id, snapshotData);
  }

  async deleteSubscriptionUsageSnapshot(id: string): Promise<void> {
    return deleteSubscriptionUsageSnapshot(id);
  }
}

export const subscriptionService = new SubscriptionService();

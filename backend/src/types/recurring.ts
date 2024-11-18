export enum RecurringFrequency {
  ONCE = 'ONCE',
  WEEKLY = 'WEEKLY',
  BIWEEKLY = 'BIWEEKLY',
  MONTHLY = 'MONTHLY'
}

export interface RecurringOrder {
  id: string;
  userId: string;
  frequency: RecurringFrequency;
  baseOrder: {
    items: OrderItem[];
    address: Address;
    preferences: OrderPreferences;
  };
  nextScheduledDate: Date;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  lastOrderId?: string;
  lastProcessedDate?: Date;
}

export interface OrderItem {
  id: string;
  name: string;
  quantity: number;
  price: number;
  notes?: string;
}

export interface Address {
  street: string;
  city: string;
  zipCode: string;
  zone: string;
  additionalInfo?: string;
  latitude?: number;
  longitude?: number;
}

export interface OrderPreferences {
  specialInstructions?: string;
  preferredTimeSlot?: {
    start: string;
    end: string;
  };
  contactPreference?: 'SMS' | 'EMAIL' | 'CALL';
}

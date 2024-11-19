import { Timestamp } from 'firebase-admin/firestore';
import { ServiceType } from './service';

export enum OrderStatus {
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
  PICKED_UP = 'PICKED_UP',
  IN_PROGRESS = 'IN_PROGRESS',
  READY = 'READY',
  DELIVERING = 'DELIVERING',
  DELIVERED = 'DELIVERED',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED'
}

export enum OrderType {
  STANDARD = 'STANDARD',
  ONE_CLICK = 'ONE_CLICK',
  SUBSCRIPTION = 'SUBSCRIPTION'
}

export enum MainService {
  PRESSING = 'PRESSING',
  REPASSAGE = 'REPASSAGE',
  NETTOYAGE_SEC = 'NETTOYAGE_SEC',
  BLANCHISSERIE = 'BLANCHISSERIE',
  DRY_CLEANING = "DRY_CLEANING",
  IRONING = "IRONING",
  WASH_AND_IRON = "WASH_AND_IRON",
  WASH_ONLY = "WASH_ONLY",
  IRON_ONLY = "IRON_ONLY",
  PICKUP_DELIVERY = "PICKUP_DELIVERY"
}

export enum AdditionalService {
  DETACHAGE = 'DETACHAGE',
  REPASSAGE_SPECIAL = 'REPASSAGE_SPECIAL',
  LIVRAISON_EXPRESS = 'LIVRAISON_EXPRESS',
  PARFUM = 'PARFUM',
  ANTI_TACHES = 'ANTI_TACHES',
  DESINFECTION = 'DESINFECTION'
}

export enum PriceType {
  FIXED = 'FIXED',
  PER_KG = 'PER_KG',
  PER_PIECE = 'PER_PIECE'
}

export enum ItemType {
  PRODUCT = 'PRODUCT',
  SERVICE = 'SERVICE'
}

export enum PaymentMethod {
  CASH = 'CASH',
  CARD = 'CARD',
  MOBILE_MONEY = 'MOBILE_MONEY'
}

export interface Location {
  latitude: number;
  longitude: number;
  address?: string;
  additionalInfo?: string;
}

export interface OrderItem {
  id?: string;
  itemType: ItemType;
  quantity: number;
  price: number;
  priceType: PriceType;
  weight?: number;
  photos?: string[];
  specialInstructions?: string;
}

export interface Order {
  id?: string;
  userId: string;
  type: OrderType;
  items: OrderItem[];
  status: OrderStatus;
  pickupAddress: string;
  pickupLocation: Location;
  deliveryAddress: string;
  deliveryLocation: Location;
  scheduledPickupTime: Timestamp;
  scheduledDeliveryTime: Timestamp;
  actualPickupTime?: Timestamp;
  actualDeliveryTime?: Timestamp;
  creationDate: Timestamp;
  updatedAt: Timestamp;
  completionDate?: Timestamp;
  totalAmount: number;
  deliveryPersonId?: string;
  zoneId: string;
  specialInstructions?: string;
  serviceType: ServiceType;
  priority?: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT';
  paymentStatus?: 'PENDING' | 'PAID' | 'FAILED' | 'REFUNDED';
  rating?: number;
  feedback?: string;
  recurringOrderId?: string; // Add recurringOrderId
}

export interface DeliverySlot {
  id?: string;
  date: Timestamp;
  startTime: string;
  endTime: string;
  maxOrders: number;
  currentOrders: number;
  zoneId: string;
  isAvailable: boolean;
  deliveryPersonId?: string;
}

export interface TimeSlot {
  startTime: string;
  endTime: string;
  availableSpots: number;
}

export interface RouteInfo {
  routeId: string;
  checkpoints: Location[];
  estimatedTime: number;
  driverNotes?: string;
}

import { Address } from "cluster";

export interface Order {
  id: string;
  userId: string;
  status: OrderStatus;
  items: OrderItem[];
  pickup: PickupDetails;
  delivery: DeliveryDetails;
  tracking: TrackingInfo;
  totalAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PICKUP_SCHEDULED = 'pickup_scheduled',
  PICKED_UP = 'picked_up',
  IN_FACILITY = 'in_facility',
  PROCESSING = 'processing',
  READY_FOR_DELIVERY = 'ready_for_delivery',
  OUT_FOR_DELIVERY = 'out_for_delivery',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled'
}

export interface PickupDetails {
  address: Address;
  scheduledDate: Date;
  timeSlot: TimeSlot;
  driverId?: string;
  notes?: string;
}

export interface DeliveryDetails {
  address: Address;
  scheduledDate: Date;
  timeSlot: TimeSlot;
  driverId?: string;
  notes?: string;
  route?: RouteInfo;
}

export interface TimeSlot {
  start: Date;
  end: Date;
  available: boolean;
}

export interface RouteInfo {
  routeId: string;
  sequence: number;
  estimatedArrival: Date;
  distance: number;
  duration: number;
}

export interface TrackingInfo {
  events: TrackingEvent[];
  currentStatus: OrderStatus;
  currentLocation?: string;
  lastUpdated: Date;
}

export interface TrackingEvent {
  status: OrderStatus;
  timestamp: Date;
  location?: string;
  notes?: string;
  updatedBy: string;
}

export interface OrderItem {
  itemId: string;
  articleName: string;
  articleCategory: string;
  service: MainService;
  additionalServices: AdditionalService[];
  priceType: PriceType;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export enum MainService {
  WASH_AND_IRON = 'wash_and_iron',
  WASH_ONLY = 'wash_only',
  IRON_ONLY = 'iron_only',
  PICKUP_DELIVERY = 'pickup_delivery'
}

export enum AdditionalService {
  DRY_CLEANING = 'dry_cleaning',
  STAIN_REMOVAL = 'stain_removal',
  DYEING = 'dyeing',
  STARCHING = 'starching',
  DUST_TREATMENT = 'dust_treatment',
  ANTI_YELLOW = 'anti_yellow'
}

export enum PriceType {
  STANDARD = 'standard',
  BASIC = 'basic'
}

export interface PaymentInfo {
  method: PaymentMethod;
  status: PaymentStatus;
  transactionId?: string;
}

export enum PaymentMethod {
  CASH = 'cash',
  CARD = 'card',
  MOBILE_MONEY = 'mobile_money'
}

export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed'
}  
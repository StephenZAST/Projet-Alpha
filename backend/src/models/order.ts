import { Address } from "./address";
import { ServiceType, PriceRange, GeoLocation } from './user';

export interface Order {
  id: string;
  userId: string;
  type: OrderType;
  status: OrderStatus;
  createdAt: Date;
  updatedAt: Date;
  collectAddress: DeliveryAddress;
  deliveryAddress: DeliveryAddress;
  items?: OrderItem[];
  serviceType: ServiceType;
  priceRange: PriceRange;
  totalWeight?: number;
  totalPrice?: number;
  appliedOffers?: string[];
  assignedDeliveryId?: string;
  collectionSlot?: TimeSlot;
  deliverySlot?: TimeSlot;
  subscriptionCollectionsLeft?: number;
  isOneClick: boolean;
  notes?: string;
}

export enum OrderType {
  STANDARD = 'standard',
  ONE_CLICK = 'one_click',
  SUBSCRIPTION = 'subscription'
}

export enum OrderStatus {
  CREATED = 'created',                    // Commande créée
  PENDING_COLLECTION = 'pending_collection', // En attente de collecte
  COLLECTED = 'collected',                // Collectée par le livreur
  PROCESSING = 'processing',              // En cours de traitement
  DETAILED = 'detailed',                  // Détaillée par la secrétaire
  READY_FOR_DELIVERY = 'ready_for_delivery', // Prête pour la livraison
  OUT_FOR_DELIVERY = 'out_for_delivery',  // En cours de livraison
  DELIVERED = 'delivered',                // Livrée
  CANCELLED = 'cancelled'                 // Annulée
}

export interface OrderItem {
  id: string;
  name: string;
  quantity: number;
  serviceType: ServiceType;
  pricePerUnit: number;
  totalPrice: number;
  category: string;
  specialInstructions?: string;
  weight?: number;
}

export interface DeliveryAddress {
  address: string;
  location: GeoLocation;
  contactName: string;
  contactPhone: string;
  instructions?: string;
}

export interface TimeSlot {
  date: Date;
  startTime: string;
  endTime: string;
  zoneId: string;
}

export interface DeliveryZone {
  id: string;
  name: string;
  boundaries: GeoLocation[];
  assignedDeliveryId?: string;
}

export interface DeliveryRoute {
  deliveryId: string;
  zoneId: string;
  orders: OrderRoutePoint[];
  optimizedRoute: GeoLocation[];
  estimatedDuration: number;
}

export interface OrderRoutePoint {
  orderId: string;
  location: GeoLocation;
  type: 'collection' | 'delivery';
  timeSlot: TimeSlot;
  status: OrderStatus;
}

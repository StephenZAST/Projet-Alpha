// src/models/user.ts
export interface User {
  uid: string;
  email: string;
  displayName: string;
  phoneNumber?: string;
  address: Address;
  role: UserRole;
  affiliateId?: string;
  creationDate: Date;
  lastLogin: Date;
  loyaltyPoints: number;
  subscriptionType?: SubscriptionType;
  defaultServicePreferences?: ServicePreferences;
  activeOffers?: string[];
  zone?: string; // Zone/quartier pour la gestion des livraisons
}

export enum UserRole {
  CLIENT = 'client',
  SUPER_ADMIN = 'super_admin',
  SERVICE_CLIENT = 'service_client',
  SECRETAIRE = 'secretaire',
  LIVREUR = 'livreur',
  SUPERVISEUR = 'superviseur'
}

export enum SubscriptionType {
  NONE = 'none',
  WEEKLY = 'weekly',
  MONTHLY = 'monthly'
}

export interface ServicePreferences {
  defaultService: ServiceType;
  priceRange: PriceRange;
  weightLimit?: number;
}

export enum ServiceType {
  BLANCHISSERIE_COMPLETE = 'blanchisserie_complete',
  REPASSAGE = 'repassage',
  NETTOYAGE_SEC = 'nettoyage_sec'
}

export enum PriceRange {
  STANDARD = 'standard',
  PREMIUM = 'premium',
  ECONOMIQUE = 'economique'
}

export interface Address {
  street: string;
  city: string;
  postalCode: string;
  country: string;
  quartier: string;
  location: GeoLocation;
  additionalInfo?: string;
}

export interface GeoLocation {
  latitude: number;
  longitude: number;
  zoneId: string; // Identifiant de la zone pour regrouper les livraisons
}

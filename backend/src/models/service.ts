export enum ServiceType {
  PRESSING = 'PRESSING',
  REPASSAGE = 'REPASSAGE',
  NETTOYAGE = 'NETTOYAGE',
  BLANCHISSERIE = 'BLANCHISSERIE'
}

export enum ServiceCategory {
  VETEMENTS = 'VETEMENTS',
  LINGE_MAISON = 'LINGE_MAISON',
  ACCESSOIRES = 'ACCESSOIRES',
  CUIR = 'CUIR',
  TAPIS = 'TAPIS'
}

export interface Service {
  id?: string;
  type: ServiceType;
  category: ServiceCategory;
  name: string;
  description: string;
  basePrice: number;
  priceType: 'FIXED' | 'PER_KG' | 'PER_PIECE';
  estimatedDuration: number; // en minutes
  isActive: boolean;
  specialInstructions?: string;
  availableAddons: string[];
}

export interface ServicePricing {
  id?: string;
  serviceId: string;
  zoneId: string;
  basePrice: number;
  rushHourMultiplier: number;
  minimumOrder: number;
  discountThresholds: {
    amount: number;
    discountPercentage: number;
  }[];
}

export interface ServiceAddon {
  id?: string;
  name: string;
  description: string;
  price: number;
  compatibleServices: ServiceType[];
  isActive: boolean;
}

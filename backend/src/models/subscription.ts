import { MainService, AdditionalService } from "./order";

export interface SubscriptionPlan {
    planId: string;
    name: string;
    price: number;
    duration: number; // in months
    servicesIncluded: MainService[];
    additionalServicesIncluded: AdditionalService[];
    itemsPerMonth: number;
    benefits: string[];
    isActive: boolean;
  }
  
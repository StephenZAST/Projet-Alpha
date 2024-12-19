import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

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
  createdAt?: string;
  updatedAt?: string;
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
  createdAt?: string;
  updatedAt?: string;
}

export interface ServiceAddon {
  id?: string;
  name: string;
  description: string;
  price: number;
  compatibleServices: ServiceType[];
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store service data
const servicesTable = 'services';
const servicePricingsTable = 'servicePricings';
const serviceAddonsTable = 'serviceAddons';

// Function to get service data
export async function getService(id: string): Promise<Service | null> {
  const { data, error } = await supabase.from(servicesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch service', 'INTERNAL_SERVER_ERROR');
  }

  return data as Service;
}

// Function to create service
export async function createService(serviceData: Service): Promise<Service> {
  const { data, error } = await supabase.from(servicesTable).insert([serviceData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create service', 'INTERNAL_SERVER_ERROR');
  }

  return data as Service;
}

// Function to update service
export async function updateService(id: string, serviceData: Partial<Service>): Promise<Service> {
  const currentService = await getService(id);

  if (!currentService) {
    throw new AppError(404, 'Service not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(servicesTable).update(serviceData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update service', 'INTERNAL_SERVER_ERROR');
  }

  return data as Service;
}

// Function to delete service
export async function deleteService(id: string): Promise<void> {
  const service = await getService(id);

  if (!service) {
    throw new AppError(404, 'Service not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(servicesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete service', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get service pricing data
export async function getServicePricing(id: string): Promise<ServicePricing | null> {
  const { data, error } = await supabase.from(servicePricingsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch service pricing', 'INTERNAL_SERVER_ERROR');
  }

  return data as ServicePricing;
}

// Function to create service pricing
export async function createServicePricing(pricingData: ServicePricing): Promise<ServicePricing> {
  const { data, error } = await supabase.from(servicePricingsTable).insert([pricingData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create service pricing', 'INTERNAL_SERVER_ERROR');
  }

  return data as ServicePricing;
}

// Function to update service pricing
export async function updateServicePricing(id: string, pricingData: Partial<ServicePricing>): Promise<ServicePricing> {
  const currentPricing = await getServicePricing(id);

  if (!currentPricing) {
    throw new AppError(404, 'Service pricing not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(servicePricingsTable).update(pricingData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update service pricing', 'INTERNAL_SERVER_ERROR');
  }

  return data as ServicePricing;
}

// Function to delete service pricing
export async function deleteServicePricing(id: string): Promise<void> {
  const pricing = await getServicePricing(id);

  if (!pricing) {
    throw new AppError(404, 'Service pricing not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(servicePricingsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete service pricing', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get service addon data
export async function getServiceAddon(id: string): Promise<ServiceAddon | null> {
  const { data, error } = await supabase.from(serviceAddonsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch service addon', 'INTERNAL_SERVER_ERROR');
  }

  return data as ServiceAddon;
}

// Function to create service addon
export async function createServiceAddon(addonData: ServiceAddon): Promise<ServiceAddon> {
  const { data, error } = await supabase.from(serviceAddonsTable).insert([addonData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create service addon', 'INTERNAL_SERVER_ERROR');
  }

  return data as ServiceAddon;
}

// Function to update service addon
export async function updateServiceAddon(id: string, addonData: Partial<ServiceAddon>): Promise<ServiceAddon> {
  const currentAddon = await getServiceAddon(id);

  if (!currentAddon) {
    throw new AppError(404, 'Service addon not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(serviceAddonsTable).update(addonData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update service addon', 'INTERNAL_SERVER_ERROR');
  }

  return data as ServiceAddon;
}

// Function to delete service addon
export async function deleteServiceAddon(id: string): Promise<void> {
  const addon = await getServiceAddon(id);

  if (!addon) {
    throw new AppError(404, 'Service addon not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(serviceAddonsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete service addon', 'INTERNAL_SERVER_ERROR');
  }
}

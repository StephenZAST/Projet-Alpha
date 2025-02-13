export type AdditionalServiceType = 'STAIN_REMOVAL' | 'PRIORITY' | 'SPECIAL_CARE' | 'CUSTOM';

export interface AdditionalService {
  id: string;
  name: string;
  type: AdditionalServiceType;
  price: number;
  description?: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface OrderAdditionalService {
  id: string;
  order_id: string;
  service_id: string;
  item_id?: string;
  notes?: string;
  price: number;
  created_at: Date;
  updated_at: Date;
  service?: AdditionalService;
}

export interface CreateAdditionalServiceDTO {
  name: string;
  type: AdditionalServiceType;
  price: number;
  description?: string;
}

export interface AddServiceToOrderDTO {
  service_id: string;
  item_id?: string;
  notes?: string;
}

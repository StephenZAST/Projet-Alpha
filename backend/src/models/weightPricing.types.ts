export interface WeightBasedPricing {
  id: string;
  min_weight: number;
  max_weight: number;
  service_type_id: string;
  price_per_kg: number;
  created_at?: Date;
  updated_at?: Date;
}

export interface OrderWeight {
  id: string;
  order_id: string;
  weight: number;
  verified_by: string;
  verified_at: Date;
  created_at: Date;
  updated_at: Date;
}

export interface CreateWeightPricingDTO {
  service_type_id: string;
  min_weight: number;
  max_weight: number;
  price_per_kg: number;
}

export interface WeightRecordDTO {
  order_id: string;
  weight: number;
}

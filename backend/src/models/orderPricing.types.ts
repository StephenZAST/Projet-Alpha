/**
 * 💰 Types pour Feature 1: Prix & Paiement
 * Gestion du prix manuel et du statut de paiement des commandes
 */

export interface OrderPricingDTO {
  manual_price?: number;
  is_paid?: boolean;
  reason?: string;
}

export interface OrderPricingResponse {
  orderId: string;
  originalPrice: number;
  manualPrice?: number;
  displayPrice: number;
  discount?: number;
  discountPercentage?: number;
  isPaid: boolean;
  paidAt?: Date;
  reason?: string;
  updatedBy?: string;
  updatedAt?: Date;
}

export interface OrderPricingData {
  id: string;
  order_id: string;
  manual_price?: number;
  is_paid: boolean;
  paid_at?: Date;
  reason?: string;
  updated_by?: string;
  updated_at?: Date;
}

export interface PricingCalculation {
  originalPrice: number;
  manualPrice?: number;
  displayPrice: number;
  discount?: number;
  discountPercentage?: number;
}

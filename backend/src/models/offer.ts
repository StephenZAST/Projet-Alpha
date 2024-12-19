export interface Offer {
    id: string;
    code: string;
    discount: number;
    description: string;
    startDate: Date;
    endDate: Date;
    createdAt: Date;
    updatedAt: Date;
    isActive: boolean;
    maxUses: number;
    usedCount: number;
    validFor: string[];
    minimumOrderAmount: number;
  }
  
  export interface CreateOfferInput {
    code: string;
    discount: number;
    description: string;
    startDate: Date;
    endDate: Date;
    isActive: boolean;
    maxUses: number;
    validFor: string[];
    minimumOrderAmount: number;
  }
  
  export interface UpdateOfferInput {
    code?: string;
    discount?: number;
    description?: string;
    startDate?: Date;
    endDate?: Date;
    isActive?: boolean;
    maxUses?: number;
    usedCount?: number;
    validFor?: string[];
    minimumOrderAmount?: number;
  }

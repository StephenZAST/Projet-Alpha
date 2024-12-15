export interface RouteInfo {
  orderId: string;
  location: any; // Changed to any for now
  type: 'pickup' | 'delivery';
  scheduledTime: string;
  status: 'pending' | 'completed';
  address: string;
  contactName?: string;
  contactPhone?: string;
}

export interface OptimizedRoute {
  deliveryPersonId: string;
  zoneId: string;
  date: string;
  stops: RouteInfo[];
  estimatedDuration: number; // en minutes
  estimatedDistance: number; // en kilomètres
  startLocation: any; // Changed to any for now
  endLocation: any; // Changed to any for now
}

export interface DeliveryTask {
  id?: string;
  deliveryPersonId: string;
  orderId: string;
  type: 'pickup' | 'delivery';
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  scheduledTime: string;
  completedTime?: string;
  location: any; // Changed to any for now
  address: string;
  notes?: string;
  proof?: {
    signature?: string;
    photo?: string;
    notes?: string;
  };
  createdAt?: string;
  updatedAt?: string;
}

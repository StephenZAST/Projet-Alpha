export interface OrderData {
  items: {
    articleId: string;
    quantity: number;
    service: string;
    additionalServices?: string[];
  }[];
  pickup: {
    address: string;
    scheduledDate: Date;
    timeSlot: {
      start: Date;
      end: Date;
    };
  };
  delivery?: {
    address: string;
    scheduledDate: Date;
    timeSlot: {
      start: Date;
      end: Date;
    };
  };
}

export interface Article {
  articleId: string;
  articleName: string;
  articleCategory: string;
  prices: Record<string, Record<string, number>>;
  availableServices: string[];
}

export interface Order {
  orderId: string;
  userId: string;
  status: string;
  items: OrderItem[];
  totalAmount: number;
  createdAt: Date;
}

export interface OrderItem {
  articleId: string;
  quantity: number;
  service: string;
  price: number;
}

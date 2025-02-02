// User related types
export type UserRole = 'SUPER_ADMIN' | 'ADMIN' | 'CLIENT' | 'AFFILIATE' | 'DELIVERY';

export interface User {
  id: string;
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone?: string;
  role: UserRole;
  referralCode?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Affiliate related types
export interface AffiliateProfile {
  id: string;
  userId: string;
  affiliateCode: string;
  parentAffiliateId?: string;
  commissionBalance: number;
  totalEarned: number;
  createdAt: Date;
  updatedAt: Date;
  commissionRate: number;
  status: 'PENDING' | 'ACTIVE' | 'SUSPENDED';
  isActive: boolean;
  totalReferrals: number;
  monthlyEarnings: number;
  levelId?: string;
  level?: AffiliateLevel;
}

export interface AffiliateLevel {
  id: string;
  name: string;
  minEarnings: number;
  commissionRate: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CommissionTransaction {
  id: string;
  affiliateId: string;
  orderId: string;
  amount: number;
  status: 'PENDING' | 'APPROVED' | 'PAID' | 'REJECTED';
  createdAt: Date;
}

// Loyalty related types
export interface LoyaltyPoints {
  id: string;
  userId: string;
  pointsBalance: number;
  totalEarned: number;
  createdAt: Date;
}

export type PointTransactionType = 'EARNED' | 'SPENT';

export type PointSource = 'ORDER' | 'REFERRAL' | 'REWARD';

export interface PointTransaction {
  id: string;
  userId: string;
  points: number;
  type: PointTransactionType;
  source: PointSource;
  referenceId: string;
  createdAt: Date;
}

// Notification related types
export type NotificationType =
  | 'ORDER_CREATED'
  | 'ORDER_STATUS_UPDATED'
  | 'ORDER_COLLECTED'
  | 'ORDER_READY'
  | 'ORDER_DELIVERED'
  | 'PAYMENT_RECEIVED'
  | 'POINTS_EARNED'
  | 'SPECIAL_OFFER'
  | 'WITHDRAWAL_REQUESTED'
  | 'WITHDRAWAL_APPROVED'
  | 'WITHDRAWAL_REJECTED'
  | 'AFFILIATE_STATUS_UPDATED'
  | 'COMMISSION_EARNED';

export interface Notification {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  data?: any;
  read: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface NotificationPreferences {
  email: boolean;
  push: boolean;
  sms: boolean;
  orderUpdates: boolean;
  promotions: boolean;
  payments: boolean;
  loyalty: boolean;
}

// Article and Service related types
export interface ArticleCategory {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
}

export interface Article {
  id: string;
  categoryId: string;
  name: string;
  description?: string;
  basePrice: number;
  premiumPrice: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface ServiceType {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
}

export interface ArticleService {
  id: string;
  articleId: string;
  serviceId: string;
  priceMultiplier: number;
  createdAt: Date;
}

export interface Service {
  id: string;
  name: string;
  price: number;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Ajout de la fonction fromJson comme une fonction utilitaire séparée
export const ServiceFromJson = (json: Record<string, any>): Service => {
  return {
    id: json.id,
    name: json.name,
    price: json.price,
    description: json.description,
    createdAt: new Date(json.createdAt),
    updatedAt: new Date(json.updatedAt),
  };
};

// Blog related types
export interface BlogCategory {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
}

export interface BlogArticle {
  id: string;
  title: string;
  content: string;
  categoryId: string;
  createdAt: Date;
  updatedAt: Date;
  authorId: string;
}

// Order related types
export interface OrderItem {
    id: string;
    orderId: string;
    articleId: string;
    serviceId: string;
    quantity: number;
    unitPrice: number;
    article?: Article;
    createdAt: Date;
    updatedAt: Date;
}

export type PaymentStatus = 'PENDING' | 'COMPLETED';
export type PaymentMethod = 'CASH' | 'ORANGE_MONEY';

export interface Order {
  id: string;
  userId: string;
  service_id: string;  
  address_id: string;  
  affiliateCode?: string;
  status: OrderStatus;
  isRecurring: boolean;
  recurrenceType: RecurrenceType | null;
  nextRecurrenceDate?: Date | null;
  totalAmount: number;
  collectionDate?: Date | null;
  deliveryDate?: Date | null;
  createdAt: Date;
  updatedAt: Date;
  service?: Service;    // Relations
  address?: Address;    // Relations
  affiliate?: AffiliateProfile; // Relations
  items?: OrderItem[];
  appliedOffers?: {
    offerId: string;
    discountAmount: number;
  }[];
  service_type_id?: string;
  paymentStatus: PaymentStatus;
  paymentMethod: PaymentMethod;
}

export type OrderStatus =
  | 'DRAFT'      // For flash orders that are not yet completed
  | 'PENDING'
  | 'COLLECTING'
  | 'COLLECTED'
  | 'PROCESSING'
  | 'READY'
  | 'DELIVERING'
  | 'DELIVERED'
  | 'CANCELLED';

export interface FlashOrder extends Omit<Order, 'serviceId' | 'items' | 'totalAmount'> {
  notes?: string;
}

export interface CompleteFlashOrderDTO {
  serviceId: string;
  serviceTypeId?: string;
  items: {
    articleId: string;
    quantity: number;
    unitPrice: number;
  }[];
  collectionDate?: Date;
  deliveryDate?: Date;
}

export type RecurrenceType = 'NONE' | 'WEEKLY' | 'BIWEEKLY' | 'MONTHLY';

export interface CreateOrderResponse {
  order: Order;
  pricing: {
    subtotal: number;
    discounts: AppliedDiscount[];
    total: number;
  };
  rewards: {
    pointsEarned: number;
    currentBalance: number;
  };
}

// Address related types
export interface Address {
  id: string;
  user_id: string;  // Changer userId à user_id pour correspondre à la BD
  name: string;
  street: string;
  city: string;
  postal_code: string;
  gps_latitude?: number;
  gps_longitude?: number;
  is_default: boolean;
  created_at: Date;
  updated_at: Date;
}

// DTO (Data Transfer Objects)
export interface RegisterDTO {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone?: string;
  affiliateCode?: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}

export interface CreateOrderDTO {
  userId: string;
  serviceId: string;
  addressId: string;
  serviceTypeId?: string;
  isRecurring: boolean;
  recurrenceType: RecurrenceType;
  collectionDate?: Date;
  deliveryDate?: Date;
  affiliateCode?: string;
  items: {
    articleId: string;
    quantity: number;
    premiumPrice?: boolean;
  }[];
  offerIds?: string[];
  paymentMethod: PaymentMethod;
}

export interface AdminCreateOrderDTO {
  customerId: string;  // ID du client pour qui l'admin crée la commande
  serviceId: string;
  addressId: string;
  serviceTypeId?: string;
  isRecurring: boolean;
  recurrenceType: RecurrenceType;
  collectionDate?: Date;
  deliveryDate?: Date;
  affiliateCode?: string;
  items: {
    articleId: string;
    quantity: number;
    isPremium?: boolean;  // Option pour le prix premium
  }[];
  offerIds?: string[];
  paymentMethod: PaymentMethod;
  adminNote?: string;  // Note optionnelle de l'administrateur
  createdBy: string;   // ID de l'admin qui crée la commande
}

export interface CreateOrderItemDTO {
    orderId: string;
  articleId: string;
  serviceId: string;
  quantity: number;
  unitPrice: number;
}

export interface OrderItemDTO {
  articleId: string;
  quantity: number;
}

export interface CreateAffiliateDTO {
  userId: string;
  parentAffiliateCode?: string;
}

export interface WithdrawCommissionDTO {
  amount: number;
  affiliateId: string;
}

// Response types
export interface AuthResponse {
  user: User;
  token: string;
  affiliateProfile?: AffiliateProfile;
}

export interface OrderResponse extends Omit<Order, 'items'> {
  items: OrderItemDetail[];
  address: Address;
  affiliate?: AffiliateProfile;
}

export interface OrderItemDetail {
  article: Article;
  service: ServiceType;
  quantity: number;
  price: number;
}

// Offer related types
export type DiscountType = 'PERCENTAGE' | 'FIXED_AMOUNT' | 'POINTS_EXCHANGE';

export interface Offer {
  id: string;
  name: string;
  description?: string;
  discountType: DiscountType;
  discountValue: number;
  minPurchaseAmount?: number;
  maxDiscountAmount?: number;
  pointsRequired?: number;
  isCumulative: boolean;
  startDate?: Date;
  endDate?: Date;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  articles?: Article[];
}

export interface CreateOfferDTO {
  name: string;
  description?: string;
  discountType: DiscountType;
  discountValue: number;
  minPurchaseAmount?: number;
  maxDiscountAmount?: number;
  pointsRequired?: number;
  isCumulative: boolean;
  startDate?: Date;
  endDate?: Date;
  articleIds?: string[];
}

export interface CreateArticleDTO {
  categoryId: string;
  name: string;
  description?: string;
  basePrice: number;
  premiumPrice: number;
}

export interface CreateArticleCategoryDTO {
  name: string;
  description?: string;
}

export interface AppliedDiscount {
  offerId: string;
  discountAmount: number;
}

export interface ResetCode {
  id: string;
  email: string;
  code: string;
  expires_at: Date;
  used: boolean;
  createdAt: Date;
}

// Archive related types
export interface OrderArchive extends Order {
  archived_at: Date;
}

export interface ArchivePagination {
  total: number;
  page: number;
  limit: number;
}

export interface OrderArchiveResponse {
  data: OrderArchive[];
  pagination: ArchivePagination;
}

// Dashboard Statistics Types
export interface DashboardStatistics {
  totalRevenue: number;
  totalOrders: number;
  totalCustomers: number;
  recentOrders: DashboardOrder[];
  ordersByStatus: Record<OrderStatus, number>;
}

export interface DashboardOrder {
  id: string;
  totalAmount: number;
  status: OrderStatus;
  createdAt: Date;
  service: {
    name: string;
  };
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
  } | null;
}

// Configuration Types
export interface SystemConfig {
  id: number;
  commission_rate: number;
  reward_points: number;
  updated_at: Date;
}

export interface RewardConfig {
  id: number;
  reward_points: number;
  reward_type: string;
  updated_at: Date;
}

// Admin Order Management Types
export interface GetAllOrdersParams {
  page: number;
  limit: number;
  status?: OrderStatus;
  startDate?: Date;
  endDate?: Date;
}

export interface PaginatedOrdersResponse {
  data: Order[];
  total: number;
}

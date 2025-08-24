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

// Types pour la gestion des utilisateurs
export interface UserListResponse {
  data: User[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface UserStats {
  total: number;
  clientCount: number;     // Ajout des propriétés spécifiques
  affiliateCount: number;
  adminCount: number;
  activeToday: number;
  newThisWeek: number;
  byRole: Record<string, number>;  // Gardons aussi cette propriété pour la rétrocompatibilité
}

export interface UserFilters {
  role?: UserRole;
  searchQuery?: string;
  startDate?: Date;
  endDate?: Date;
  status?: 'active' | 'inactive';
}

export interface UserUpdateDTO {
  email?: string;
  firstName?: string;
  lastName?: string;
  phone?: string;
  role?: UserRole;
}

export interface UserCreateDTO {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone?: string;
  role: UserRole;
}

export interface UserActivityLog {
  id: string;
  userId: string;
  action: string;
  details?: any;
  ipAddress?: string;
  userAgent?: string;
  createdAt: Date;
}

// Affiliate related types
export interface NotificationSettings {
  email: boolean;
  push: boolean;
  sms: boolean;
  order_updates: boolean;
  promotions: boolean;
  payments: boolean;
  loyalty: boolean;
}

export interface AffiliateProfile {
  id: string;
  userId: string;
  affiliateCode: string;
  parent_affiliate_id?: string;     
  commission_rate: number;          
  commissionBalance: number;
  totalEarned: number;
  monthlyEarnings: number;
  isActive: boolean;
  notificationPreferences?: NotificationSettings;  // Ajout de cette propriété
  status: 'PENDING' | 'ACTIVE' | 'SUSPENDED' | null;
  levelId?: string;
  level?: {              // Ajout de la propriété level
    id: string;
    name: string;
    minEarnings: number;
    commissionRate: number;
    createdAt: Date;
    updatedAt: Date;
  };
  totalReferrals?: number;
  createdAt: Date;
  updatedAt: Date;
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
  user_id: string;
  pointsBalance: number;      // camelCase comme dans la BD
  totalEarned: number;
  createdAt: Date;
  updatedAt: Date;
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
export enum NotificationType {
  ORDER_STATUS = 'ORDER_STATUS',
  ORDER_CREATED = 'ORDER_CREATED',
  ORDER_STATUS_UPDATED = 'ORDER_STATUS_UPDATED',
  SERVICE_ADDED = 'SERVICE_ADDED',  // Ajout du nouveau type
  SERVICE_CREATED = 'SERVICE_CREATED',
  SERVICE_UPDATED = 'SERVICE_UPDATED',
  SERVICE_TYPE_CREATED = 'SERVICE_TYPE_CREATED',
  SERVICE_TYPE_UPDATED = 'SERVICE_TYPE_UPDATED',
  WEIGHT_RECORDED = 'WEIGHT_RECORDED',
  SUBSCRIPTION_CREATED = 'SUBSCRIPTION_CREATED',
  SUBSCRIPTION_CANCELLED = 'SUBSCRIPTION_CANCELLED',
  AFFILIATE_STATUS_UPDATED = 'AFFILIATE_STATUS_UPDATED',
  POINTS_EARNED = 'POINTS_EARNED',
  REFERRAL_BONUS = 'REFERRAL_BONUS',
  PROMOTIONS = 'PROMOTIONS',
  PRICE_UPDATED = 'PRICE_UPDATED',
  OFFER_CREATED = 'OFFER_CREATED',
  OFFER_UPDATED = 'OFFER_UPDATED', 
  OFFER_DELETED = 'OFFER_DELETED',
  OFFER_SUBSCRIBED = 'OFFER_SUBSCRIBED',
  OFFER_UNSUBSCRIBED = 'OFFER_UNSUBSCRIBED',
  ARTICLE_CREATED = 'ARTICLE_CREATED',
  // Ajout des nouveaux types
  WITHDRAWAL_REQUESTED = 'WITHDRAWAL_REQUESTED',
  WITHDRAWAL_PROCESSED = 'WITHDRAWAL_PROCESSED',
  WITHDRAWAL_REJECTED = 'WITHDRAWAL_REJECTED',
  COMMISSION_EARNED = 'COMMISSION_EARNED'
}

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

export interface NotificationData {
  orderId?: string;
  message: string;
  type: NotificationType;
  data?: any;
  title?: string;
}

export interface NotificationCreateDTO {
  userId: string;
  type: NotificationType;
  title?: string;
  message: string;
  data?: any;
}

export interface NotificationPreference {
  id: string;
  user_id: string;
  order_updates: boolean;
  promotions: boolean;
  system_updates: boolean;
  email_notifications: boolean;
  push_notifications: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface NotificationRule {
  id: string;
  event_type: NotificationType;
  user_role: UserRole;
  template: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface NotificationTemplate {
  orderId: string;
  clientName: string;
  amount: number;
  deliveryZone: string;
  itemCount: number;
  title?: string;
  message?: string;
}

export interface RoleBasedNotificationData {
  userId: string;
  role: UserRole;
  templateData: NotificationTemplate;
  customData?: Record<string, any>;
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

export interface ArticleUpdateDTO {
  name?: string;
  description?: string;
  basePrice?: number;
  premiumPrice?: number;
  categoryId?: string;
}

export interface ServiceType {
  id: string;
  name: string;
  description?: string;
  is_default: boolean;
  requires_weight: boolean;
  supports_premium: boolean;
  is_active: boolean;  // Ajout de cette propriété
  created_at: Date;
  updated_at: Date;
  pricing_type?: string;
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
  service_type_id?: string;
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
    service_type_id: json.service_type_id,
  };
};

export interface ArticleServicePrice {
  id: string;
  article_id: string;
  service_type_id: string;
  base_price: number;
  premium_price?: number;
  is_available: boolean;
  price_per_kg?: number;
  created_at: string;
  updated_at: string;
  service_type?: ServiceType;
}

export interface CreateServiceTypeDTO {
  name: string;
  description?: string;
  isDefault?: boolean;
  requiresWeight?: boolean;
  supportsPremium?: boolean;
}

export interface UpdateServiceTypeDTO {
  name?: string;
  description?: string;
  isDefault?: boolean;
  isActive?: boolean;
  requiresWeight?: boolean;
  supportsPremium?: boolean;
}

export interface ArticleServiceUpdate {
  service_type_id: string;
  base_price?: number;
  premium_price?: number;
  price_per_kg?: number;
  is_available: boolean;
}

export interface ServiceConfiguration {
  serviceTypes: ServiceType[];
  defaultService: ServiceType | null;
  configuration: {
    allowPricePerKg: boolean;
    allowPremiumPrices: boolean;
  };
}

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
  isPremium?: boolean;  // Ajout du champ manquant
  weight?: number;
    article?: Article;
    createdAt: Date;
    updatedAt: Date;
}

export enum PaymentMethod {
  CASH = 'CASH',
  ORANGE_MONEY = 'ORANGE_MONEY',
  
}

export enum PaymentStatus {
  PENDING = 'PENDING',
  PAID = 'PAID',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED'
}

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
  notes?: (string | null)[];
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
  notes?: (string | null)[];
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
  isSubscriptionOrder?: boolean;
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

export interface OrderItemInput {
  articleId: string;
  quantity: number;
  isPremium?: boolean;
  weight?: number;
  premiumPrice?: boolean;  // Support des deux formats pour la rétrocompatibilité
}

export interface CreateOrderDTO {
  userId: string;
  serviceId: string;
  addressId: string;
  isRecurring: boolean;
  recurrenceType: RecurrenceType;
  collectionDate?: Date;
  deliveryDate?: Date;
  affiliateCode?: string;
  items: OrderItemInput[];
  offerIds?: string[];
  appliedOfferIds?: string[];  // Ajout du champ manquant
  paymentMethod: PaymentMethod;
  service_type_id?: string;
  serviceTypeId?: string;
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
  isPremium?: boolean;
  weight?: number;
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
  subscribers?: OfferSubscription[];
}

export interface OfferSubscription {
  id: string;
  user_id: string;
  offer_id: string;
  status: 'ACTIVE' | 'INACTIVE';
  subscribed_at: Date;
  updated_at: Date;
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

export interface SubscriptionPlan {
  id: string;
  name: string;
  description?: string;
  price: number;
  duration_days: number;
  max_orders_per_month: number;
  max_weight_per_order?: number;
  is_premium: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface UserSubscription {
  id: string;
  userId: string;
  planId: string;
  startDate: Date;
  endDate: Date;
  status: 'ACTIVE' | 'CANCELLED' | 'EXPIRED';
  remainingWeight: number;
  remainingOrders: number;
  expired: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface AdditionalService {
  id: string;
  name: string;
  description?: string;
  basePrice: number;
  premiumPrice?: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface PriceHistoryEntry {
  id: string;
  article_id: string;
  service_type_id: string;
  old_price: {
    base_price?: number;
    premium_price?: number;
    price_per_kg?: number;
  };
  new_price: {
    base_price?: number;
    premium_price?: number;
    price_per_kg?: number;
  };
  modified_by: string;
  created_at: Date;
  modifier?: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
  };
}


export interface ServiceSpecificPrice {
  id: string;
  article_id: string;
  service_id: string;
  base_price: number;
  premium_price?: number;
  is_available: boolean;
  created_at: Date;
  updated_at: Date;
}

// Ajout des nouveaux types pour la gestion des services et des prix
export interface ServicePricingBase {
  base_price?: number;
  premium_price?: number;
  price_per_kg?: number;
  is_available?: boolean;
}


export interface ArticleServiceUpdate extends ServicePricingBase {
  service_type_id: string;
  service_id?: string;
  is_available: boolean;  // Override pour rendre obligatoire
}

export interface SetPricesDTO extends ServicePricingBase {
  service_type_id?: string;
}

// Mise à jour du type ArticleServicePrice
export interface ArticleServicePrice extends ServicePricingBase {
  id: string;
  article_id: string;
  service_type_id: string;
  service_id?: string; // Optionnel pour correspondre à la réalité de la base et éviter les erreurs de création
  base_price: number;     // Champs obligatoires pour la BD
  premium_price?: number;
  price_per_kg?: number;
  is_available: boolean;  // Champ obligatoire pour la BD
  created_at: string;
  updated_at: string;
  service_type?: ServiceType;
}

// Ajout des types pour la notification de service
export interface ServiceNotification {
  serviceId: string;
  type: NotificationType;
  changes: Record<string, any>;
  affectedUsers?: string[];
}

// Ajout des types pour le calcul des prix
export interface PriceCalculationResult {
  total: number;
  breakdown: PriceBreakdownItem[];
}

export interface PriceBreakdownItem {
  type: 'WEIGHT' | 'ITEM';
  cost: number;
  details: any;
}

// Types pour les services spécifiques
export interface ServiceSpecificPrice {
  id: string;
  article_id: string;
  service_id: string;
  base_price: number;
  premium_price?: number;
  is_available: boolean;
  created_at: Date;
  updated_at: Date;
}

// Types pour la validation du poids
export interface WeightValidationResult {
  isValid: boolean;
  message?: string;
  pricing?: {
    price_per_kg: number;
    total: number;
  };
}

// Types pour le calcul de prix
export interface PriceCalculationParams {
  articleId: string;
  serviceTypeId: string;
  quantity?: number;
  weight?: number;
  isPremium?: boolean;
}

export interface PriceDetails {
  basePrice: number;
  total: number;
  pricingType: PricingType;
  isPremium: boolean;
}

export type PricingType = 'PER_ITEM' | 'PER_WEIGHT' | 'SUBSCRIPTION' | 'FIXED';

export interface NotificationCreate {
  user_id: string;
  type: NotificationType;
  message: string;
  data?: Record<string, any>;
  read?: boolean;
  created_at?: string;
  updated_at?: string;
}

// Ajout de l'option pour utiliser des points
export interface PricingOptions {
  items: OrderItem[];
  userId?: string;
  appliedOfferIds?: string[];
  usePoints?: number;  // Ajout de l'option pour utiliser des points
}

export interface LoyaltyDiscount {
  type: 'LOYALTY';
  amount: number;
  pointsUsed: number;
}

// Ajout des interfaces manquantes
export interface Discount {
  type: 'LOYALTY' | 'OFFER';
  amount: number;
  offerId: string;
}

export interface PricingResult {
  subtotal: number;
  discounts: Discount[];
  total: number;
}

// Ajout des interfaces manquantes
export interface OrderAdditionalService {
  id: string;
  orderId: string;
  serviceId: string;
  price: number;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateAdditionalServiceDTO {
  name: string;
  description?: string;
  basePrice: number;
}
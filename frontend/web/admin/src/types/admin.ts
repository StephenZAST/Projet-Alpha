export enum AdminRole {
    MASTER = 'MASTER_SUPER_ADMIN',
    SUPER = 'SUPER_ADMIN',
    SECRETARY = 'SECRETARY',
    DELIVERY = 'DELIVERY_PERSON',
    CUSTOMER_SERVICE = 'CUSTOMER_SERVICE',
    SUPERVISOR = 'SUPERVISOR'
}

export interface AdminUser {
    id: string;
    role: AdminRole;
    name: string;
    email: string;
    phone: string; // Added phone property
    permissions: string[];
    lastActive: Date;
}

export interface DashboardConfig {
    metrics: MetricConfig[];
    features: string[];
    permissions: string[];
    theme: ThemeConfig;
}

export interface MetricConfig {
    id: string;
    type: 'number' | 'currency' | 'percentage';
    label: string;
    value: number;
    change?: number;
    trend?: 'up' | 'down' | 'neutral';
}

export interface ThemeConfig {
    primaryColor: string;
    secondaryColor: string;
    accentColor: string;
    isDark: boolean;
}

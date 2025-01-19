export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
  phone?: string;
  referral_code?: string | null;
  created_at: string;
  updated_at: string;
  addresses?: Address[];
}

export type UserRole = 'SUPER_ADMIN' | 'ADMIN' | 'DELIVERY';

export interface Address {
  id: string;
  city: string;
  name: string | null;
  street: string;
  user_id: string;
  created_at: string;
  is_default: boolean;
  updated_at: string;
  postal_code: string;
  gps_latitude: number;
  gps_longitude: number;
}

export interface Permission {
  resource: string;
  actions: ('create' | 'read' | 'update' | 'delete')[];
}

export const ROLE_PERMISSIONS: Record<UserRole, Permission[]> = {
  SUPER_ADMIN: [
    { resource: 'users', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'affiliates', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'orders', actions: ['read', 'update'] }
  ],
  ADMIN: [
    { resource: 'affiliates', actions: ['read', 'update'] },
    { resource: 'orders', actions: ['read', 'update'] }
  ],
  DELIVERY: [
    { resource: 'orders', actions: ['read', 'update'] }
  ]
};

export const hasPermission = (role: UserRole, resource: string, action: 'create' | 'read' | 'update' | 'delete'): boolean => {
  const permissions = ROLE_PERMISSIONS[role];
  return permissions.some(p => 
    p.resource === resource && p.actions.includes(action)
  );
};

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  error: string | null;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface LoginResponse {
  success: boolean;
  data: {
    user: User;
    token: string;
  };
}

export type AuthAction =
  | { type: 'LOGIN_SUCCESS'; payload: { user: User; token: string } }
  | { type: 'LOGIN_FAIL'; payload: string }
  | { type: 'LOGOUT' }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'CLEAR_ERROR' }
  | { type: 'UPDATE_PROFILE_SUCCESS'; payload: User }
  | { type: 'UPDATE_PROFILE_FAIL'; payload: string };

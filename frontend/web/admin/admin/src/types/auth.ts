export interface User {
  id: string;
  email: string;
  role: UserRole;
  firstName: string;
  lastName: string;
}

export type UserRole = 'SUPER_ADMIN' | 'ADMIN' | 'DELIVERY';

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
  error?: string | null;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export type AuthAction =
  | { type: 'LOGIN_SUCCESS'; payload: { user: User; token: string } }
  | { type: 'LOGIN_FAIL'; payload: string }
  | { type: 'LOGOUT' }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'CLEAR_ERROR' };

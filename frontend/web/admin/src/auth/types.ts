import { AdminType } from '../dashboard/types/adminTypes';

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  adminType: AdminType;
  avatar?: string;
  permissions: string[];
  lastLogin?: Date;
  isActive: boolean;
}

export interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  loading: boolean;
  error: string | null;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthContextType {
  isAuthenticated: boolean;
  user: User | null;
  loading: boolean;
  error: string | null;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  updateUser: (user: Partial<User>) => Promise<void>;
}

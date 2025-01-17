export interface UserSettings {
  notifications: {
    email: boolean;
    push: boolean;
  };
  theme: 'light' | 'dark';
  language: 'en' | 'fr';
}

export interface UserProfile {
  firstName: string;
  lastName: string;
  email: string;
  avatar?: string;
  role: UserRole;
}

export type SettingsTab = 'profile' | 'preferences';

export interface FormError {
  type: string;
  message: string;
}

export interface FormState {
  loading: boolean;
  error: string | null;
  success: boolean;
}

import { UserRole } from './user';

export interface IAdmin {
  id: string;
  userId: string;
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  phoneNumber: string;
  isActive: boolean;
  createdBy: string;
  lastLogin?: Date;
  createdAt: Date;
  updatedAt: Date;
  permissions: string[];
  isMasterAdmin: boolean;
  googleAIKey?: string;
}

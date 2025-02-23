import { UserRole } from '../models/types';

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        userId: string;
        role: UserRole;
      }
    }
  }
}

export {};

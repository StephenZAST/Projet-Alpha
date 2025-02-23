import { UserRole } from '../../models/types';

declare module 'express-serve-static-core' {
  interface Request {
    user?: {
      id: string;
      userId: string;
      role: UserRole;
    }
  }
}

export {};

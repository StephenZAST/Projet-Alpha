import { NextFunction, Request, Response } from 'express';
import * as jwt from 'jsonwebtoken';
import { User, UserRole } from '../models/user';
// import { DecodedToken } from '../utils/jwt';
interface DecodedToken {
  uid: string;
  email?: string;
  name?: string;
  phone_number?: string;
  role?: UserRole;
  email_verified?: boolean;
}

declare global {
  namespace Express {
    interface Request {
      user?: User;
    }
  }
}

export const auth = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      throw new Error('Authentication required');
    }

    const decodedToken = jwt.verify(token, process.env.JWT_SECRET!) as DecodedToken;

    req.user = {
      id: decodedToken.uid,
      uid: decodedToken.uid,
      profile: {
        firstName: decodedToken.name?.split(' ')[0] || '',
        lastName: decodedToken.name?.split(' ')[1] || '',
        email: decodedToken.email || '',
        phoneNumber: decodedToken.phone_number || '',
        lastUpdated: new Date(),
      },
      role: decodedToken.role as UserRole || UserRole.CLIENT,
      status: UserStatus.ACTIVE,
      creationMethod: AccountCreationMethod.SELF_REGISTRATION,
      emailVerified: decodedToken.email_verified || false,
      loyaltyPoints: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
      firstName: decodedToken.name?.split(' ')[0] || '',
      lastName: decodedToken.name?.split(' ')[1] || '',
      phoneNumber: decodedToken.phone_number || '',
      displayName: decodedToken.name || '',
      email: decodedToken.email || '',
    };

    next();
  } catch (error) {
    res.status(401).send({ error: 'Not authorized' });
  }
};

export const isAuthenticated = auth;
export const requireAdminRole = (allowedRoles: UserRole[]) => (req: Request, res: Response, next: NextFunction) => {
  if (req.user && allowedRoles.includes(req.user.role)) {
    next();
  } else {
    res.status(403).json({ message: 'Forbidden - Insufficient role' });
  }
};

enum UserStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
  DELETED = 'DELETED'
}

enum AccountCreationMethod {
  SELF_REGISTRATION = 'SELF_REGISTRATION',
  ADMIN_CREATED = 'ADMIN_CREATED',
  AFFILIATE_REFERRAL = 'AFFILIATE_REFERRAL',
  CUSTOMER_REFERRAL = 'CUSTOMER_REFERRAL'
}

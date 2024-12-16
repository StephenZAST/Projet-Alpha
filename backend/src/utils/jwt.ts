import jwt from 'jsonwebtoken';
import { IAdmin } from '../models/admin';
import { AppError, errorCodes } from './errors';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'; 
const JWT_EXPIRES_IN = '24h';

interface DecodedToken {
  id: string;
  role: string;
  isMasterAdmin: boolean;
}

export const generateToken = (admin: IAdmin): string => {
  return jwt.sign(
    {
      id: admin.id,
      role: admin.role,
      isMasterAdmin: admin.isMasterAdmin,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
};

export const verifyToken = (token: string): DecodedToken => {
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    return decoded as DecodedToken;
  } catch (error: any) {
    if (error.name === 'TokenExpiredError') {
      throw new AppError(401, 'Token expired', errorCodes.UNAUTHORIZED);
    } else if (error.name === 'JsonWebTokenError') {
      throw new AppError(401, 'Invalid token', errorCodes.UNAUTHORIZED);
    } else {
      throw new AppError(401, 'Token verification failed', errorCodes.UNAUTHORIZED);
    }
  }
};

export const decodeToken = (token: string): DecodedToken | null => {
  try {
    const decoded = jwt.decode(token);
    return decoded as DecodedToken;
  } catch (error) {
    return null;
  }
};

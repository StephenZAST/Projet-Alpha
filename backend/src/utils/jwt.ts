import jwt from 'jsonwebtoken';
import { IAdmin } from '../models/admin';
import { AppError, errorCodes } from './errors';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const JWT_EXPIRES_IN = '24h';

export const generateToken = (admin: IAdmin): string => {
    return jwt.sign(
        { 
            id: admin._id,
            role: admin.role,
            isMasterAdmin: admin.isMasterAdmin
        },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
    );
};

export const verifyToken = (token: string): any => {
    try {
        return jwt.verify(token, JWT_SECRET);
    } catch (error) {
        throw new AppError(401, 'Token invalide ou expiré', errorCodes.UNAUTHORIZED);
    }
};

export const decodeToken = (token: string): any => {
    return jwt.decode(token);
};

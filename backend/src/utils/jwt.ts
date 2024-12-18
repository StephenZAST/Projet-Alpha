import jwt from 'jsonwebtoken';
import { UserRole } from '../models/user';

interface TokenPayload {
    uid: string;
    email: string;
    role: UserRole;
}

export const generateToken = (payload: TokenPayload): string => {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new Error('JWT_SECRET environment variable not set.');
    }
    return jwt.sign(
        payload,
        secret,
        {
            expiresIn: '1h',
        }
    );
};

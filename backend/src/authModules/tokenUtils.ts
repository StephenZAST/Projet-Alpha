import * as jwt from 'jsonwebtoken';
import { config } from 'dotenv';

config(); // Load environment variables

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('JWT_SECRET is not defined in environment variables');
}

export const createToken = (payload: { id: string; role: string }): string => {
  // Generate a token using jsonwebtoken
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '1h' });
};

export const verifyToken = (token: string): { id: string; role: string } | null => {
  // Verify a token using jsonwebtoken
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as { id: string; role: string };
    return decoded;
  } catch (error) {
    return null;
  }
};

export const generateSupabaseToken = (user: any): string => {
  // Generate JWT token using our utility
  return jwt.sign({
    uid: user.id,
    email: user.email,
    role: user.role || 'user',
  }, JWT_SECRET, { expiresIn: '1h' });
};

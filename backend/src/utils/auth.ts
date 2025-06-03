import jwt from 'jsonwebtoken';
import { config } from '../config';

interface TokenUser {
  id: string;
  email: string;
  role: string;
  first_name: string;
  last_name: string;
}

export const generateToken = (user: TokenUser): string => {
  try {
    return jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name,
      },
      process.env.JWT_SECRET || 'your-secret-key',
      {
        expiresIn: '24h', // Token expire après 24h
      }
    );
  } catch (error) {
    console.error('Error generating token:', error);
    throw new Error('Failed to generate authentication token');
  }
};

export const verifyToken = (token: string): TokenUser => {
  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'your-secret-key'
    ) as TokenUser;
    return decoded;
  } catch (error) {
    console.error('Error verifying token:', error);
    throw new Error('Invalid authentication token');
  }
};

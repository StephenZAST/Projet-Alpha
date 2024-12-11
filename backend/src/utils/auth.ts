import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { IAdmin } from '../models/admin';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import { config } from 'dotenv';
import { NextFunction, Request, Response } from 'express';

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

export const hashPassword = async (password: string): Promise<string> => {
  // Hash a password using bcryptjs
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
};

export const comparePassword = async (password: string, hashedPassword: string): Promise<boolean> => {
  // Compare a password with a hashed password using bcryptjs
  return await bcrypt.compare(password, hashedPassword);
};

export const authenticateAdmin = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return next(new AppError(401, 'Token is required', 'UNAUTHORIZED'));
  }

  const decoded = verifyToken(token);

  if (!decoded) {
    return next(new AppError(401, 'Invalid token', 'UNAUTHORIZED'));
  }

  // Fetch the admin from the database using the decoded id
  const admin = (req as any).user = decoded.id;

  next();
};

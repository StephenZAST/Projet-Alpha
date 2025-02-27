import { Request, Response, NextFunction } from 'express';
import { UserStats } from '../models/types';

export const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

export const validatePassword = (password: string): boolean => {
  return password.length >= 6;
};

export const validatePhone = (phone: string): boolean => {
  const phoneRegex = /^\+?[1-9]\d{1,14}$/;
  return phoneRegex.test(phone);
};

export const validateUUID = (uuid: string): boolean => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
}; 

export const validateUserStats = (stats: Partial<UserStats>): UserStats => {
  return {
    total: Number(stats.total) || 0,
    clientCount: Number(stats.clientCount) || 0,
    affiliateCount: Number(stats.affiliateCount) || 0,
    adminCount: Number(stats.adminCount) || 0,
    activeToday: Number(stats.activeToday) || 0,
    newThisWeek: Number(stats.newThisWeek) || 0,
    byRole: stats.byRole || {}
  };
};

export const ensureValidDate = (date: Date | string | null): Date => {
  if (!date) return new Date();
  return new Date(date);
};

export const validateRegistration = (req: Request, res: Response, next: NextFunction) => {
  const { email, password, firstName, lastName, phone } = req.body;
  
  // Validation des données
  if (!email || !password || !firstName || !lastName) {
    res.status(400).json({ error: 'Missing required fields' });
    return;
  }
  
  if (!validateEmail(email)) {
    res.status(400).json({ error: 'Invalid email format' });
    return;
  }

  if (!validatePassword(password)) {
    res.status(400).json({ error: 'Password must be at least 6 characters' });
    return;
  }

  if (phone && !validatePhone(phone)) {
    res.status(400).json({ error: 'Invalid phone number format' });
    return;
  }

  next();
};

export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
  const { email, password } = req.body;
  
  // Validation des données
  if (!email || !password) {
    res.status(400).json({ error: 'Email and password are required' });
    return;
  }

  if (!validateEmail(email)) {
    res.status(400).json({ error: 'Invalid email format' });
    return;
  }

  next();
};

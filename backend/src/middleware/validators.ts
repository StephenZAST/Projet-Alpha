import { Request, Response, NextFunction } from 'express';
import { validateEmail, validatePassword, validatePhone } from '../utils/validators';
import { z } from 'zod';

// Schémas de validation
const pointsRedemptionSchema = z.object({
  points: z.number().positive('Points must be positive'),
  rewardId: z.string().uuid('Invalid reward ID')
});

const notificationPreferencesSchema = z.object({
  emailNotifications: z.boolean(),
  pushNotifications: z.boolean(),
  types: z.array(z.enum(['ORDER_STATUS', 'POINTS_EARNED', 'REFERRAL_BONUS', 'PROMOTIONS']))
});

const claimRewardSchema = z.object({
  rewardId: z.string().uuid('Invalid reward ID')
});

export const validateRegistration = (req: Request, res: Response, next: NextFunction): void => {
  const { email, password, firstName, lastName } = req.body;

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

  next();
}; 

export const validateLogin = (req: Request, res: Response, next: NextFunction): void => {
  const { email, password } = req.body;

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

export const validateAffiliateCreation = (req: Request, res: Response, next: NextFunction) => {
  const { parentAffiliateCode } = req.body;

  if (parentAffiliateCode && typeof parentAffiliateCode !== 'string') {
    return res.status(400).json({ error: 'Invalid affiliate code format' });
  }

  next();
};

export const validatePointsRedemption = (req: Request, res: Response, next: NextFunction) => {
  try {
    pointsRedemptionSchema.parse(req.body);
    next();
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ 
        error: 'Validation failed', 
        details: error.errors 
      });
    } else {
      next(error);
    }
  }
};

export const validateNotificationPreferences = (req: Request, res: Response, next: NextFunction) => {
  try {
    notificationPreferencesSchema.parse(req.body);
    next();
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ 
        error: 'Validation failed', 
        details: error.errors 
      });
    } else {
      next(error);
    }
  }
};

export const validateClaimReward = (req: Request, res: Response, next: NextFunction) => {
  try {
    claimRewardSchema.parse(req.body);
    next();
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ 
        error: 'Validation failed', 
        details: error.errors 
      });
    } else {
      next(error);
    }
  }
};

export const validateOrder = (req: Request, res: Response, next: NextFunction) => {
  console.log('Validating order request:', req.body);
  const { serviceId, addressId, items } = req.body;

  if (!serviceId || !addressId || !items || !Array.isArray(items) || items.length === 0) {
    console.log('Validation failed: Missing required fields or invalid items array');
    return res.status(400).json({ error: 'Missing required fields' });
  }

  // Check if each item has articleId and quantity
  for (const item of items) {
    if (!item.articleId || typeof item.quantity !== 'number' || item.quantity <= 0) {
      console.log('Validation failed: Invalid item format', item);
      return res.status(400).json({ error: 'Invalid item format' });
    }
  }

  console.log('Order validation successful');
  next();
};

export const validateLocation = (req: Request, res: Response, next: NextFunction) => {
  const { location } = req.body;

  if (!location || typeof location.latitude !== 'number' || typeof location.longitude !== 'number') {
    return res.status(400).json({ error: 'Invalid location format' });
  }

  if (location.latitude < -90 || location.latitude > 90 || 
      location.longitude < -180 || location.longitude > 180) {
    return res.status(400).json({ error: 'Invalid coordinates' });
  }

  next();
};

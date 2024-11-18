import { Request, Response, NextFunction } from 'express';
import { db } from '../config/firebase';

export const isAdmin = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized: No user found' });
    }

    const userDoc = await db.collection('users').doc(req.user.id).get();
    
    if (!userDoc.exists) {
      return res.status(401).json({ error: 'Unauthorized: User not found' });
    }

    const userData = userDoc.data();
    
    if (!userData?.role || userData.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Forbidden: Admin access required' });
    }

    next();
  } catch (error) {
    console.error('Error in admin middleware:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
};

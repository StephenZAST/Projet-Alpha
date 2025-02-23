import { Request, Response, NextFunction } from 'express';

export const validateSubscription = (req: Request, res: Response, next: NextFunction) => {
  try {
    const { planId } = req.body;

    if (!planId) {
      return res.status(400).json({
        success: false,
        error: 'Plan ID is required'
      });
    }

    // Validation UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(planId)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid plan ID format'
      });
    }

    next();
  } catch (error: any) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
};
  
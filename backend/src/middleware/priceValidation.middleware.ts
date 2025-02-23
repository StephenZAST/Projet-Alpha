import { Request, Response, NextFunction } from 'express';

export const validatePriceData = (req: Request, res: Response, next: NextFunction) => {
  const { base_price, premium_price, price_per_kg } = req.body;

  if (!base_price && !price_per_kg) {
    return res.status(400).json({
      message: "Au moins un prix (base_price ou price_per_kg) doit être défini"
    });
  }

  if (premium_price && premium_price <= base_price) {
    return res.status(400).json({
      message: "Le prix premium doit être supérieur au prix de base"
    });
  }

  next();
};
  
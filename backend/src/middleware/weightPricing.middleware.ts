import { Request, Response, NextFunction } from 'express';

export const validateWeightPricing = (req: Request, res: Response, next: NextFunction) => {
  try {
    const { min_weight, max_weight, price_per_kg, service_id } = req.body;

    if (!min_weight || !max_weight || !price_per_kg || !service_id) {
      return res.status(400).json({
        success: false,
        message: "Tous les champs requis doivent être remplis"
      });
    }

    if (min_weight >= max_weight) {
      return res.status(400).json({
        success: false,
        message: "Le poids minimum doit être inférieur au poids maximum"
      });
    }

    if (min_weight < 0 || max_weight < 0 || price_per_kg < 0) {
      return res.status(400).json({
        success: false,
        message: "Les valeurs ne peuvent pas être négatives"
      });
    }

    next();
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error instanceof Error ? error.message : "Une erreur est survenue"
    });
  }
};

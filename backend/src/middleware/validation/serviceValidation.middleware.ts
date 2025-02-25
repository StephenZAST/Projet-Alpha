import { Request, Response, NextFunction } from 'express';
import { validateUUID } from '../../utils/validators'; 

export const validateServiceTypeCreate = (req: Request, res: Response, next: NextFunction) => {
  const { name, description } = req.body;

  if (!name || typeof name !== 'string' || name.length < 2) {
    return res.status(400).json({
      success: false,
      message: 'Le nom du service doit contenir au moins 2 caractères'
    });
  }

  if (description && typeof description !== 'string') {
    return res.status(400).json({
      success: false,
      message: 'La description doit être une chaîne de caractères'
    });
  }

  next();
};

export const validateWeightPricing = (req: Request, res: Response, next: NextFunction) => {
  const { service_type_id, min_weight, max_weight, price_per_kg } = req.body;

  if (!validateUUID(service_type_id)) {
    return res.status(400).json({
      success: false,
      message: 'ID de type de service invalide'
    });
  }  

  if (!min_weight || !max_weight || !price_per_kg) {
    return res.status(400).json({
      success: false,
      message: 'Tous les champs de tarification sont requis'
    });
  }

  if (min_weight >= max_weight) {
    return res.status(400).json({
      success: false,
      message: 'Le poids minimum doit être inférieur au poids maximum'
    });
  }

  if (price_per_kg <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Le prix par kg doit être supérieur à 0'
    });
  }

  next();
};

export const validateServiceCompatibility = (req: Request, res: Response, next: NextFunction) => {
  const { article_id, service_id, is_compatible } = req.body;

  if (!validateUUID(article_id) || !validateUUID(service_id)) {
    return res.status(400).json({
      success: false,
      message: 'IDs invalides'
    });
  }

  if (typeof is_compatible !== 'boolean') {
    return res.status(400).json({
      success: false,
      message: 'La compatibilité doit être un booléen'
    });
  }

  next();
};

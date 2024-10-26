// src/middleware/validation.ts
import Joi from 'joi';
import { Request, Response, NextFunction } from 'express';

export const validateOrder = (req: Request, res: Response, next: NextFunction) => {
  const schema = Joi.object({
    userId: Joi.string().required(),
    serviceType: Joi.string().required(),
    items: Joi.array().min(1).required(),
    // Add more validation rules
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  next();
};

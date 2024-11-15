// src/middleware/validation.ts
import { Request, Response, NextFunction } from 'express';
import { Schema } from 'joi';
import * as Joi from 'joi';

// Middleware générique de validation
export const validate = (schema: Schema, property: 'body' | 'query' | 'params' = 'body') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req[property], { abortEarly: false });
    
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      
      return res.status(400).json({
        status: 'error',
        message: 'Validation error',
        errors
      });
    }
    
    next();
  };
};

// Middleware de validation avec transformation
export const validateAndTransform = (schema: Schema, property: 'body' | 'query' | 'params' = 'body') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error, value } = schema.validate(req[property], {
      abortEarly: false,
      stripUnknown: true // Supprime les champs non définis dans le schéma
    });
    
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      
      return res.status(400).json({
        status: 'error',
        message: 'Validation error',
        errors
      });
    }
    
    // Met à jour la requête avec les données validées et transformées
    req[property] = value;
    next();
  };
};

// Middleware de validation avec pagination
export const validatePagination = (req: Request, res: Response, next: NextFunction) => {
  const schema = Joi.object({
    page: Joi.number().min(1).default(1),
    limit: Joi.number().min(1).max(100).default(10)
  });

  const { error, value } = schema.validate(req.query);
  
  if (error) {
    return res.status(400).json({
      status: 'error',
      message: 'Invalid pagination parameters',
      errors: error.details
    });
  }

  req.query = {
    ...req.query,
    page: value.page,
    limit: value.limit
  };

  next();
};

// Middleware de validation des ID MongoDB
export const validateMongoId = (paramName: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const id = req.params[paramName];
    
    if (!/^[0-9a-fA-F]{24}$/.test(id)) {
      return res.status(400).json({
        status: 'error',
        message: `Invalid ${paramName} format`
      });
    }
    
    next();
  };
};

// Middleware de validation des dates
export const validateDateRange = (
  startDateField: string = 'startDate',
  endDateField: string = 'endDate'
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const startDate = new Date(req.query[startDateField] as string);
    const endDate = new Date(req.query[endDateField] as string);

    if (isNaN(startDate.getTime())) {
      return res.status(400).json({
        status: 'error',
        message: `Invalid ${startDateField} format`
      });
    }

    if (isNaN(endDate.getTime())) {
      return res.status(400).json({
        status: 'error',
        message: `Invalid ${endDateField} format`
      });
    }

    if (startDate > endDate) {
      return res.status(400).json({
        status: 'error',
        message: `${startDateField} cannot be later than ${endDateField}`
      });
    }

    next();
  };
};

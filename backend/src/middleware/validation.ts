import { Request, Response, NextFunction } from 'express';
import { Schema } from 'joi';
import * as Joi from 'joi';
import { AppError, errorCodes } from '../utils/errors';

// Middleware générique de validation
export const validate = (schema: Schema, property: 'body' | 'query' | 'params' = 'body') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req[property], { abortEarly: false });

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return next(new AppError(400, 'Validation error', errorCodes.VALIDATION_ERROR, errors));
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

      return next(new AppError(400, 'Validation error', errorCodes.VALIDATION_ERROR, errors));
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
    return next(new AppError(400, 'Invalid pagination parameters', errorCodes.VALIDATION_ERROR, error.details));
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
      return next(new AppError(400, `Invalid ${paramName} format`, errorCodes.VALIDATION_ERROR));
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
      return next(new AppError(400, `Invalid ${startDateField} format`, errorCodes.VALIDATION_ERROR));
    }

    if (isNaN(endDate.getTime())) {
      return next(new AppError(400, `Invalid ${endDateField} format`, errorCodes.VALIDATION_ERROR));
    }

    if (startDate > endDate) {
      return next(new AppError(400, `${startDateField} cannot be later than ${endDateField}`, errorCodes.VALIDATION_ERROR));
    }

    next();
  };
};

// Middleware de validation générique pour les requêtes
export const validateRequest = (req: Request, res: Response, next: NextFunction) => {
  // Example validation logic
  const { body } = req;

  if (!body) {
    return next(new AppError(400, 'Request body is required', 'INVALID_REQUEST'));
  }

  next();
};

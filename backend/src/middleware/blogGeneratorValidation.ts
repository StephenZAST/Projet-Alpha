import { Request, Response, NextFunction } from 'express';
import { supabase } from '../config';
import AppError from '../utils/AppError';
import Joi from 'joi';

const blogGeneratorConfigSchema = Joi.object({
  title: Joi.string().required().min(5).max(100)
    .messages({
      'string.empty': 'Le titre est requis',
      'string.min': 'Le titre doit contenir au moins 5 caractères',
      'string.max': 'Le titre ne doit pas dépasser 100 caractères'
    }),
  content: Joi.string().required().min(100)
    .messages({
      'string.empty': 'Le contenu est requis',
      'string.min': 'Le contenu doit contenir au moins 100 caractères'
    }),
  category: Joi.string().required().min(2).max(50)
    .messages({
      'string.empty': 'La catégorie est requise',
      'string.min': 'La catégorie doit contenir au moins 2 caractères',
      'string.max': 'La catégorie ne doit pas dépasser 50 caractères'
    }),
  tags: Joi.array().items(Joi.string()).min(1).max(5)
    .messages({
      'array.min': 'Au moins un tag est requis',
      'array.max': 'Maximum 5 tags autorisés'
    }),
  featuredImage: Joi.string().uri().optional()
    .messages({
      'string.uri': "L'URL de l'image n'est pas valide"
    }),
  seoTitle: Joi.string().max(60).optional()
    .messages({
      'string.max': 'Le titre SEO ne doit pas dépasser 60 caractères'
    }),
  seoDescription: Joi.string().max(160).optional()
    .messages({
      'string.max': 'La description SEO ne doit pas dépasser 160 caractères'
    }),
  seoKeywords: Joi.array().items(Joi.string()).max(10).optional()
    .messages({
      'array.max': 'Maximum 10 mots-clés SEO autorisés'
    })
});

export const validateBlogGenerationConfig = async (req: Request, res: Response, next: NextFunction) => {
  const { authorization } = req.headers;

  if (!authorization) {
    return next(new AppError(401, 'Authorization header is required', 'UNAUTHORIZED'));
  }

  const token = authorization.split(' ')[1];

  if (!token) {
    return next(new AppError(401, 'Token is required', 'UNAUTHORIZED'));
  }

  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data?.user) {
    return next(new AppError(401, 'Invalid token', 'UNAUTHORIZED'));
  }

  (req as any).user = data.user;

  const { error: validationError } = blogGeneratorConfigSchema.validate(req.body, { abortEarly: false });

  if (validationError) {
    const errors = validationError.details.map(detail => detail.message);
    return next(new AppError(400, 'Validation failed', 'VALIDATION_ERROR', errors));
  }

  next();
};

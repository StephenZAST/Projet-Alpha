import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { BlogArticleCategory, BlogArticleStatus } from '../models/blogArticle';

const blogArticleSchema = Joi.object({
  title: Joi.string().required().min(5).max(200)
    .messages({
      'string.empty': 'Le titre est requis',
      'string.min': 'Le titre doit contenir au moins 5 caractères',
      'string.max': 'Le titre ne doit pas dépasser 200 caractères'
    }),
  content: Joi.string().required().min(100)
    .messages({
      'string.empty': 'Le contenu est requis',
      'string.min': 'Le contenu doit contenir au moins 100 caractères'
    }),
  category: Joi.string().valid(...Object.values(BlogArticleCategory)).required()
    .messages({
      'any.required': 'La catégorie est requise',
      'any.only': 'Catégorie invalide'
    }),
  tags: Joi.array().items(Joi.string()).min(1).max(5).required()
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

const updateBlogArticleSchema = blogArticleSchema.keys({
  title: Joi.string().min(5).max(200).optional(),
  content: Joi.string().min(100).optional(),
  category: Joi.string().valid(...Object.values(BlogArticleCategory)).optional(),
  tags: Joi.array().items(Joi.string()).min(1).max(5).optional(),
  status: Joi.string().valid(...Object.values(BlogArticleStatus)).optional()
});

export const validateCreateBlogArticle = async (req: Request, res: Response, next: NextFunction) => {
  const { authorization } = req.headers;

  if (!authorization) {
    return next(new AppError(401, 'Authorization header is required', errorCodes.UNAUTHORIZED));
  }

  const token = authorization.split(' ')[1];

  if (!token) {
    return next(new AppError(401, 'Token is required', errorCodes.UNAUTHORIZED));
  }

  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data?.user) {
    return next(new AppError(401, 'Invalid token', errorCodes.UNAUTHORIZED));
  }

  (req as any).user = data.user;

  const { error: validationError } = blogArticleSchema.validate(req.body, { abortEarly: false });

  if (validationError) {
    const errors = validationError.details.map(detail => detail.message);
    throw new AppError(400, errors.join(', '), errorCodes.VALIDATION_ERROR);
  }

  next();
};

export const validateUpdateBlogArticle = async (req: Request, res: Response, next: NextFunction) => {
  const { authorization } = req.headers;

  if (!authorization) {
    return next(new AppError(401, 'Authorization header is required', errorCodes.UNAUTHORIZED));
  }

  const token = authorization.split(' ')[1];

  if (!token) {
    return next(new AppError(401, 'Token is required', errorCodes.UNAUTHORIZED));
  }

  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data?.user) {
    return next(new AppError(401, 'Invalid token', errorCodes.UNAUTHORIZED));
  }

  (req as any).user = data.user;

  const { error: validationError } = updateBlogArticleSchema.validate(req.body, { abortEarly: false });

  if (validationError) {
    const errors = validationError.details.map(detail => detail.message);
    throw new AppError(400, errors.join(', '), errorCodes.VALIDATION_ERROR);
  }

  next();
};

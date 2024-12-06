import Joi from 'joi';
import { ArticleStatus, ArticleType } from '../../models/article';

// Base price schema
const priceSchema = Joi.object({
  amount: Joi.number().positive().required().messages({
    'number.positive': 'Le montant doit être positif',
    'any.required': 'Le montant est requis'
  }),
  unit: Joi.string().valid('piece', 'kg', 'set').required().messages({
    'any.only': 'Unité invalide',
    'any.required': 'L\'unité est requise'
  })
});

// Image schema
const imageSchema = Joi.object({
  url: Joi.string().uri().required().messages({
    'string.uri': 'L\'URL de l\'image n\'est pas valide',
    'any.required': 'L\'URL de l\'image est requise'
  }),
  alt: Joi.string().required().messages({
    'any.required': 'Le texte alternatif est requis'
  })
});

// Create article schema
export const createArticleSchema = Joi.object({
  name: Joi.string().required().messages({
    'any.required': 'Le nom est requis'
  }),
  description: Joi.string().required().messages({
    'any.required': 'La description est requise'
  }),
  type: Joi.string().valid(...Object.values(ArticleType)).required().messages({
    'any.only': 'Type d\'article invalide',
    'any.required': 'Le type d\'article est requis'
  }),
  categoryId: Joi.string().required().messages({
    'any.required': 'L\'ID de la catégorie est requis'
  }),
  prices: Joi.object().pattern(
    Joi.string(),
    priceSchema
  ).required().messages({
    'any.required': 'Les prix sont requis'
  }),
  images: Joi.array().items(imageSchema).min(1).required().messages({
    'array.min': 'Au moins une image est requise',
    'any.required': 'Les images sont requises'
  }),
  specifications: Joi.object().pattern(
    Joi.string(),
    Joi.string()
  ),
  careInstructions: Joi.array().items(Joi.string()),
  status: Joi.string().valid(...Object.values(ArticleStatus)).default(ArticleStatus.ACTIVE),
  tags: Joi.array().items(Joi.string()),
  featured: Joi.boolean().default(false)
});

// Update article schema
export const updateArticleSchema = Joi.object({
  name: Joi.string(),
  description: Joi.string(),
  type: Joi.string().valid(...Object.values(ArticleType)),
  categoryId: Joi.string(),
  prices: Joi.object().pattern(
    Joi.string(),
    priceSchema
  ),
  images: Joi.array().items(imageSchema).min(1),
  specifications: Joi.object().pattern(
    Joi.string(),
    Joi.string()
  ),
  careInstructions: Joi.array().items(Joi.string()),
  status: Joi.string().valid(...Object.values(ArticleStatus)),
  tags: Joi.array().items(Joi.string()),
  featured: Joi.boolean()
}).min(1).messages({
  'object.min': 'Au moins un champ doit être fourni pour la mise à jour'
});

// Search articles schema
export const searchArticlesSchema = Joi.object({
  query: Joi.string(),
  categoryId: Joi.string(),
  type: Joi.string().valid(...Object.values(ArticleType)),
  status: Joi.string().valid(...Object.values(ArticleStatus)),
  featured: Joi.boolean(),
  minPrice: Joi.number().min(0),
  maxPrice: Joi.number().min(Joi.ref('minPrice')).messages({
    'number.min': 'Le prix maximum doit être supérieur au prix minimum'
  }),
  tags: Joi.array().items(Joi.string()),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'name', 'price').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Bulk update status schema
export const bulkUpdateStatusSchema = Joi.object({
  articleIds: Joi.array().items(Joi.string()).min(1).required().messages({
    'array.min': 'Au moins un ID d\'article est requis',
    'any.required': 'Les IDs des articles sont requis'
  }),
  status: Joi.string().valid(...Object.values(ArticleStatus)).required().messages({
    'any.only': 'Statut invalide',
    'any.required': 'Le statut est requis'
  })
});

// Article review schema
export const articleReviewSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'utilisateur est requis'
  }),
  rating: Joi.number().integer().min(1).max(5).required().messages({
    'number.min': 'La note doit être entre 1 et 5',
    'number.max': 'La note doit être entre 1 et 5',
    'any.required': 'La note est requise'
  }),
  comment: Joi.string().max(500).messages({
    'string.max': 'Le commentaire ne peut pas dépasser 500 caractères'
  }),
  images: Joi.array().items(imageSchema).max(5).messages({
    'array.max': 'Maximum 5 images autorisées'
  })
});

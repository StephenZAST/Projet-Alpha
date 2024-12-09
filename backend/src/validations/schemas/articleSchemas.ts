import Joi from 'joi';
import { ArticleStatus, ArticleType } from '../../models/article';
import { errorCodes } from '../../utils/errors';

// Base price schema
const priceSchema = Joi.object({
  amount: Joi.number().positive().required().messages({
    'number.positive': errorCodes.INVALID_PRICE_RANGE,
    'any.required': errorCodes.INVALID_PRICE_RANGE
  }),
  unit: Joi.string().valid('piece', 'kg', 'set').required().messages({
    'any.only': errorCodes.INVALID_PRICE_RANGE,
    'any.required': errorCodes.INVALID_PRICE_RANGE
  })
});

// Image schema
const imageSchema = Joi.object({
  url: Joi.string().uri().required().messages({
    'string.uri': errorCodes.INVALID_ARTICLE_DATA,
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  alt: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  })
});

// Create article schema
export const createArticleSchema = Joi.object({
  name: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  description: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  type: Joi.string().valid(...Object.values(ArticleType)).required().messages({
    'any.only': errorCodes.INVALID_ARTICLE_DATA,
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  categoryId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  prices: Joi.object().pattern(
    Joi.string(),
    priceSchema
  ).required().messages({
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  images: Joi.array().items(imageSchema).min(1).required().messages({
    'array.min': errorCodes.INVALID_ARTICLE_DATA,
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  specifications: Joi.object().pattern(
    Joi.string(),
    Joi.string()
  ),
  careInstructions: Joi.array().items(Joi.string()),
  status: Joi.string().valid(...Object.values(ArticleStatus)).default(ArticleStatus.ACTIVE).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  tags: Joi.array().items(Joi.string()),
  featured: Joi.boolean().default(false)
});

// Update article schema
export const updateArticleSchema = Joi.object({
  name: Joi.string().messages({
    'string.empty': errorCodes.INVALID_ARTICLE_DATA
  }),
  description: Joi.string().messages({
    'string.empty': errorCodes.INVALID_ARTICLE_DATA
  }),
  type: Joi.string().valid(...Object.values(ArticleType)).messages({
    'any.only': errorCodes.INVALID_ARTICLE_DATA
  }),
  categoryId: Joi.string().messages({
    'string.empty': errorCodes.INVALID_ARTICLE_DATA
  }),
  prices: Joi.object().pattern(
    Joi.string(),
    priceSchema
  ),
  images: Joi.array().items(imageSchema).min(1).messages({
    'array.min': errorCodes.INVALID_ARTICLE_DATA
  }),
  specifications: Joi.object().pattern(
    Joi.string(),
    Joi.string()
  ),
  careInstructions: Joi.array().items(Joi.string()),
  status: Joi.string().valid(...Object.values(ArticleStatus)).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  tags: Joi.array().items(Joi.string()),
  featured: Joi.boolean()
}).min(1).messages({
  'object.min': errorCodes.VALIDATION_ERROR
});

// Search articles schema
export const searchArticlesSchema = Joi.object({
  query: Joi.string(),
  categoryId: Joi.string(),
  type: Joi.string().valid(...Object.values(ArticleType)),
  status: Joi.string().valid(...Object.values(ArticleStatus)).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  featured: Joi.boolean(),
  minPrice: Joi.number().min(0).messages({
    'number.min': errorCodes.INVALID_PRICE_RANGE
  }),
  maxPrice: Joi.number().min(Joi.ref('minPrice')).messages({
    'number.min': errorCodes.INVALID_PRICE_RANGE
  }),
  tags: Joi.array().items(Joi.string()),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'name', 'price').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
}).messages({
  'object.unknown': errorCodes.VALIDATION_ERROR
});

// Bulk update status schema
export const bulkUpdateStatusSchema = Joi.object({
  articleIds: Joi.array().items(Joi.string()).min(1).required().messages({
    'array.min': errorCodes.INVALID_ARTICLE_DATA,
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  status: Joi.string().valid(...Object.values(ArticleStatus)).required().messages({
    'any.only': errorCodes.INVALID_STATUS,
    'any.required': errorCodes.INVALID_STATUS
  })
});

// Article review schema
export const articleReviewSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  rating: Joi.number().integer().min(1).max(5).required().messages({
    'number.min': errorCodes.INVALID_ARTICLE_DATA,
    'number.max': errorCodes.INVALID_ARTICLE_DATA,
    'any.required': errorCodes.INVALID_ARTICLE_DATA
  }),
  comment: Joi.string().max(500).messages({
    'string.max': errorCodes.INVALID_ARTICLE_DATA
  }),
  images: Joi.array().items(imageSchema).max(5).messages({
    'array.max': errorCodes.INVALID_ARTICLE_DATA
  })
});

import Joi from 'joi';
import { CategoryStatus } from '../../models/category';
import { errorCodes } from '../../utils/errors';

// Image schema
const categoryImageSchema = Joi.object({
  url: Joi.string().uri().required().messages({
    'string.uri': errorCodes.INVALID_CATEGORY_DATA,
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  }),
  alt: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  })
});

// Create category schema
export const createCategorySchema = Joi.object({
  name: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  }),
  description: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  }),
  parentId: Joi.string().allow(null).messages({
    'string.base': errorCodes.INVALID_CATEGORY_DATA
  }),
  image: categoryImageSchema,
  icon: Joi.string().messages({
    'string.base': errorCodes.INVALID_CATEGORY_DATA
  }),
  status: Joi.string().valid(...Object.values(CategoryStatus)).default(CategoryStatus.ACTIVE).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  displayOrder: Joi.number().integer().min(0).default(0).messages({
    'number.base': errorCodes.INVALID_CATEGORY_DATA,
    'number.integer': errorCodes.INVALID_CATEGORY_DATA,
    'number.min': errorCodes.INVALID_CATEGORY_DATA
  }),
  slug: Joi.string().pattern(/^[a-z0-9-]+$/).required().messages({
    'string.pattern.base': errorCodes.INVALID_CATEGORY_DATA,
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  }),
  metadata: Joi.object({
    title: Joi.string(),
    description: Joi.string(),
    keywords: Joi.array().items(Joi.string())
  })
});

// Update category schema
export const updateCategorySchema = Joi.object({
  name: Joi.string().messages({
    'string.min': errorCodes.INVALID_CATEGORY_DATA,
    'string.max': errorCodes.INVALID_CATEGORY_DATA
  }),
  description: Joi.string().messages({
    'string.max': errorCodes.INVALID_CATEGORY_DATA
  }),
  parentId: Joi.string().allow(null).messages({
    'string.base': errorCodes.INVALID_CATEGORY_DATA
  }),
  image: categoryImageSchema,
  icon: Joi.string().messages({
    'string.uri': errorCodes.INVALID_CATEGORY_DATA
  }),
  status: Joi.string().valid(...Object.values(CategoryStatus)).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  displayOrder: Joi.number().integer().min(0).messages({
    'number.base': errorCodes.INVALID_CATEGORY_DATA,
    'number.integer': errorCodes.INVALID_CATEGORY_DATA,
    'number.min': errorCodes.INVALID_CATEGORY_DATA
  }),
  slug: Joi.string().pattern(/^[a-z0-9-]+$/).messages({
    'string.pattern.base': errorCodes.INVALID_CATEGORY_DATA
  }),
  metadata: Joi.object({
    title: Joi.string(),
    description: Joi.string(),
    keywords: Joi.array().items(Joi.string())
  })
}).min(1).messages({
  'object.min': errorCodes.VALIDATION_ERROR
});

// Search categories schema
export const searchCategoriesSchema = Joi.object({
  query: Joi.string(),
  parentId: Joi.string().allow(null),
  status: Joi.string().valid(...Object.values(CategoryStatus)).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  page: Joi.number().integer().min(1).default(1).messages({
    'number.base': errorCodes.INVALID_CATEGORY_DATA,
    'number.integer': errorCodes.INVALID_CATEGORY_DATA,
    'number.min': errorCodes.INVALID_CATEGORY_DATA
  }),
  limit: Joi.number().integer().min(1).max(100).default(10).messages({
    'number.base': errorCodes.INVALID_CATEGORY_DATA,
    'number.integer': errorCodes.INVALID_CATEGORY_DATA,
    'number.min': errorCodes.INVALID_CATEGORY_DATA,
    'number.max': errorCodes.INVALID_CATEGORY_DATA
  }),
  sortBy: Joi.string().valid('name', 'createdAt', 'displayOrder').default('displayOrder'),
  sortOrder: Joi.string().valid('asc', 'desc').default('asc')
});

// Bulk update categories schema
export const bulkUpdateCategoriesSchema = Joi.object({
  categoryIds: Joi.array().items(Joi.string()).min(1).required().messages({
    'array.min': errorCodes.INVALID_CATEGORY_DATA,
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  }),
  status: Joi.string().valid(...Object.values(CategoryStatus)).required().messages({
    'any.only': errorCodes.INVALID_STATUS,
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  })
});

// Reorder categories schema
export const reorderCategoriesSchema = Joi.object({
  categoryOrders: Joi.array().items(
    Joi.object({
      categoryId: Joi.string().required(),
      displayOrder: Joi.number().integer().min(0).required()
    })
  ).min(1).required().messages({
    'array.min': errorCodes.INVALID_CATEGORY_DATA,
    'any.required': errorCodes.INVALID_CATEGORY_DATA
  })
});

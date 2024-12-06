import Joi from 'joi';
import { CategoryStatus } from '../../models/category';

// Image schema
const categoryImageSchema = Joi.object({
  url: Joi.string().uri().required().messages({
    'string.uri': 'L\'URL de l\'image n\'est pas valide',
    'any.required': 'L\'URL de l\'image est requise'
  }),
  alt: Joi.string().required().messages({
    'any.required': 'Le texte alternatif est requis'
  })
});

// Create category schema
export const createCategorySchema = Joi.object({
  name: Joi.string().required().messages({
    'any.required': 'Le nom est requis'
  }),
  description: Joi.string().required().messages({
    'any.required': 'La description est requise'
  }),
  parentId: Joi.string().allow(null).messages({
    'string.base': 'L\'ID parent doit être une chaîne de caractères'
  }),
  image: categoryImageSchema,
  icon: Joi.string().messages({
    'string.base': 'L\'icône doit être une chaîne de caractères'
  }),
  status: Joi.string().valid(...Object.values(CategoryStatus)).default(CategoryStatus.ACTIVE).messages({
    'any.only': 'Statut invalide'
  }),
  displayOrder: Joi.number().integer().min(0).default(0).messages({
    'number.base': 'L\'ordre d\'affichage doit être un nombre',
    'number.integer': 'L\'ordre d\'affichage doit être un nombre entier',
    'number.min': 'L\'ordre d\'affichage doit être positif'
  }),
  slug: Joi.string().pattern(/^[a-z0-9-]+$/).required().messages({
    'string.pattern.base': 'Le slug ne doit contenir que des lettres minuscules, des chiffres et des tirets',
    'any.required': 'Le slug est requis'
  }),
  metadata: Joi.object({
    title: Joi.string(),
    description: Joi.string(),
    keywords: Joi.array().items(Joi.string())
  })
});

// Update category schema
export const updateCategorySchema = Joi.object({
  name: Joi.string(),
  description: Joi.string(),
  parentId: Joi.string().allow(null),
  image: categoryImageSchema,
  icon: Joi.string(),
  status: Joi.string().valid(...Object.values(CategoryStatus)),
  displayOrder: Joi.number().integer().min(0),
  slug: Joi.string().pattern(/^[a-z0-9-]+$/),
  metadata: Joi.object({
    title: Joi.string(),
    description: Joi.string(),
    keywords: Joi.array().items(Joi.string())
  })
}).min(1).messages({
  'object.min': 'Au moins un champ doit être fourni pour la mise à jour'
});

// Search categories schema
export const searchCategoriesSchema = Joi.object({
  query: Joi.string(),
  parentId: Joi.string().allow(null),
  status: Joi.string().valid(...Object.values(CategoryStatus)),
  page: Joi.number().integer().min(1).default(1).messages({
    'number.base': 'La page doit être un nombre',
    'number.integer': 'La page doit être un nombre entier',
    'number.min': 'La page doit être supérieure à 0'
  }),
  limit: Joi.number().integer().min(1).max(100).default(10).messages({
    'number.base': 'La limite doit être un nombre',
    'number.integer': 'La limite doit être un nombre entier',
    'number.min': 'La limite doit être supérieure à 0',
    'number.max': 'La limite ne peut pas dépasser 100'
  }),
  sortBy: Joi.string().valid('name', 'createdAt', 'displayOrder').default('displayOrder'),
  sortOrder: Joi.string().valid('asc', 'desc').default('asc')
});

// Bulk update categories schema
export const bulkUpdateCategoriesSchema = Joi.object({
  categoryIds: Joi.array().items(Joi.string()).min(1).required().messages({
    'array.min': 'Au moins un ID de catégorie est requis',
    'any.required': 'Les IDs des catégories sont requis'
  }),
  status: Joi.string().valid(...Object.values(CategoryStatus)).required().messages({
    'any.only': 'Statut invalide',
    'any.required': 'Le statut est requis'
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
    'array.min': 'Au moins une catégorie est requise',
    'any.required': 'L\'ordre des catégories est requis'
  })
});

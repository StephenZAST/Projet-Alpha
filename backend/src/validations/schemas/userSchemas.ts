import Joi from 'joi';
import { AccountCreationMethod } from '../../models/user';

// Base address schema that can be reused
const addressSchema = Joi.object({
  street: Joi.string().required().messages({
    'any.required': 'La rue est requise'
  }),
  city: Joi.string().required().messages({
    'any.required': 'La ville est requise'
  }),
  postalCode: Joi.string().required().messages({
    'any.required': 'Le code postal est requis'
  }),
  country: Joi.string().required().messages({
    'any.required': 'Le pays est requis'
  }),
  quartier: Joi.string().required().messages({
    'any.required': 'Le quartier est requis'
  }),
  location: Joi.object({
    latitude: Joi.number().required().messages({
      'any.required': 'La latitude est requise'
    }),
    longitude: Joi.number().required().messages({
      'any.required': 'La longitude est requise'
    }),
    zoneId: Joi.string().required().messages({
      'any.required': 'L\'ID de la zone est requis'
    })
  }).required(),
  additionalInfo: Joi.string()
});

// Base user schema that can be reused
const baseUserSchema = {
  email: Joi.string().email().required().messages({
    'string.email': 'Veuillez fournir une adresse email valide',
    'any.required': 'L\'email est requis'
  }),
  displayName: Joi.string().required().messages({
    'any.required': 'Le nom est requis'
  }),
  phoneNumber: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/).messages({
    'string.pattern.base': 'Le numéro de téléphone n\'est pas valide'
  }),
  address: addressSchema,
  language: Joi.string().valid('fr', 'en').default('fr'),
  avatar: Joi.string().uri().messages({
    'string.uri': 'L\'URL de l\'avatar n\'est pas valide'
  })
};

// Customer registration schema
export const customerRegistrationSchema = Joi.object({
  ...baseUserSchema,
  password: Joi.string().min(8).required().messages({
    'string.min': 'Le mot de passe doit contenir au moins 8 caractères',
    'any.required': 'Le mot de passe est requis'
  }),
  affiliateCode: Joi.string(),
  sponsorCode: Joi.string(),
  creationMethod: Joi.string().valid(
    AccountCreationMethod.SELF_REGISTRATION,
    AccountCreationMethod.ADMIN_CREATED,
    AccountCreationMethod.AFFILIATE_REFERRAL,
    AccountCreationMethod.CUSTOMER_REFERRAL
  ).required()
});

// Admin customer creation schema
export const adminCustomerCreationSchema = customerRegistrationSchema.keys({
  createdBy: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'administrateur est requis'
  })
});

// Password related schemas
export const passwordResetRequestSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Veuillez fournir une adresse email valide',
    'any.required': 'L\'email est requis'
  })
});

export const passwordResetSchema = Joi.object({
  token: Joi.string().required().messages({
    'any.required': 'Le token de réinitialisation est requis'
  }),
  newPassword: Joi.string().min(8).required().messages({
    'string.min': 'Le nouveau mot de passe doit contenir au moins 8 caractères',
    'any.required': 'Le nouveau mot de passe est requis'
  })
});

// Email verification schema
export const emailVerificationSchema = Joi.object({
  token: Joi.string().required().messages({
    'any.required': 'Le token de vérification est requis'
  })
});

// Profile update schemas
export const updateProfileSchema = Joi.object({
  displayName: Joi.string().min(2).messages({
    'string.min': 'Le nom doit contenir au moins 2 caractères'
  }),
  phoneNumber: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/).messages({
    'string.pattern.base': 'Le numéro de téléphone n\'est pas valide'
  }),
  email: Joi.string().email().messages({
    'string.email': 'Veuillez fournir une adresse email valide'
  }),
  avatar: Joi.string().uri().messages({
    'string.uri': 'L\'URL de l\'avatar n\'est pas valide'
  }),
  language: Joi.string().valid('fr', 'en').messages({
    'any.only': 'La langue doit être "fr" ou "en"'
  })
}).min(1).messages({
  'object.min': 'Au moins un champ doit être fourni pour la mise à jour'
});

export const updateAddressSchema = addressSchema;

// Query params schema for user listing
export const userListQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  search: Joi.string().allow(''),
  role: Joi.string().valid('user', 'admin', 'affiliate'),
  status: Joi.string().valid('active', 'inactive', 'suspended'),
  sortBy: Joi.string().valid('createdAt', 'email', 'displayName'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

import Joi from 'joi';
import { AccountCreationMethod } from '../models/user';

export const customerRegistrationSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Veuillez fournir une adresse email valide',
    'any.required': 'L\'email est requis'
  }),
  password: Joi.string().min(8).required().messages({
    'string.min': 'Le mot de passe doit contenir au moins 8 caractères',
    'any.required': 'Le mot de passe est requis'
  }),
  displayName: Joi.string().required().messages({
    'any.required': 'Le nom est requis'
  }),
  phoneNumber: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/).messages({
    'string.pattern.base': 'Le numéro de téléphone n\'est pas valide'
  }),
  address: Joi.object({
    street: Joi.string().required(),
    city: Joi.string().required(),
    postalCode: Joi.string().required(),
    country: Joi.string().required(),
    quartier: Joi.string().required(),
    location: Joi.object({
      latitude: Joi.number().required(),
      longitude: Joi.number().required(),
      zoneId: Joi.string().required()
    }).required(),
    additionalInfo: Joi.string()
  }),
  affiliateCode: Joi.string(), // Optional affiliate code
  sponsorCode: Joi.string(),  // Optional sponsor code
  creationMethod: Joi.string().valid(
    AccountCreationMethod.SELF_REGISTERED,
    AccountCreationMethod.ADMIN_CREATED,
    AccountCreationMethod.AFFILIATE_CREATED,
    AccountCreationMethod.REFERRED
  ).required()
});

export const adminCustomerCreationSchema = customerRegistrationSchema.keys({
  createdBy: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'administrateur est requis'
  })
});

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

export const emailVerificationSchema = Joi.object({
  token: Joi.string().required().messages({
    'any.required': 'Le token de vérification est requis'
  })
});

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

export const updateAddressSchema = Joi.object({
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

export const updatePreferencesSchema = Joi.object({
  notifications: Joi.object({
    email: Joi.boolean(),
    push: Joi.boolean(),
    sms: Joi.boolean()
  }),
  orderPreferences: Joi.object({
    defaultPaymentMethod: Joi.string().valid('cash', 'card', 'mobile_money'),
    defaultPickupTime: Joi.string(),
    defaultDeliveryTime: Joi.string()
  }),
  marketingPreferences: Joi.object({
    receivePromotions: Joi.boolean(),
    receiveNewsletter: Joi.boolean()
  })
}).min(1).messages({
  'object.min': 'Au moins une préférence doit être fournie pour la mise à jour'
});

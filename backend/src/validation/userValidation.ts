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
    AccountCreationMethod.SELF_REGISTRATION,
    AccountCreationMethod.ADMIN_CREATED,
    AccountCreationMethod.AFFILIATE_REFERRAL,
    AccountCreationMethod.CUSTOMER_REFERRAL
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

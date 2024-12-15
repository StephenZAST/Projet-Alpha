import Joi from 'joi';
import { UserRole } from '../models/user';

// Schéma pour la création d'un utilisateur
export const createUserSchema = Joi.object({
  email: Joi.string().email().required()
    .messages({
      'string.email': 'Format d\'email invalide',
      'any.required': 'Email est requis',
      'string.empty': 'Email ne peut pas être vide'
    }),
  password: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
    .required()
    .messages({
      'string.pattern.base': 'Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial',
      'any.required': 'Mot de passe est requis',
      'string.empty': 'Mot de passe ne peut pas être vide'
    }),
  firstName: Joi.string().required()
    .messages({
      'any.required': 'Prénom est requis',
      'string.empty': 'Prénom ne peut pas être vide'
    }),
  lastName: Joi.string().required()
    .messages({
      'any.required': 'Nom est requis',
      'string.empty': 'Nom ne peut pas être vide'
    }),
  phone: Joi.string().pattern(/^\+?[0-9]{10,15}$/).required()
    .messages({
      'string.pattern.base': 'Format de numéro de téléphone invalide',
      'any.required': 'Numéro de téléphone est requis',
      'string.empty': 'Numéro de téléphone ne peut pas être vide'
    }),
  role: Joi.string().valid(...Object.values(UserRole)).required()
    .messages({
      'any.only': 'Rôle invalide',
      'any.required': 'Rôle est requis',
      'string.empty': 'Rôle ne peut pas être vide'
    }),
  address: Joi.string().required()
    .messages({
      'any.required': 'Adresse est requise',
      'string.empty': 'Adresse ne peut pas être vide'
    }),
  defaultLocation: Joi.object({
    latitude: Joi.number().min(-90).max(90).required()
      .messages({
        'any.required': 'Latitude est requise',
        'number.min': 'Latitude doit être supérieure ou égale à -90',
        'number.max': 'Latitude doit être inférieure ou égale à 90'
      }),
    longitude: Joi.number().min(-180).max(180).required()
      .messages({
        'any.required': 'Longitude est requise',
        'number.min': 'Longitude doit être supérieure ou égale à -180',
        'number.max': 'Longitude doit être inférieure ou égale à 180'
      })
  }).required(),
  creationMethod: Joi.string().valid(
    'self_registration',
    'admin_created',
    'affiliate_referral',
    'customer_referral'
  ).required()
    .messages({
      'any.only': 'Méthode de création invalide',
      'any.required': 'Méthode de création est requise',
      'string.empty': 'Méthode de création ne peut pas être vide'
    })
});

// Schéma pour la mise à jour d'un utilisateur
export const updateUserSchema = Joi.object({
  firstName: Joi.string(),
  lastName: Joi.string(),
  phone: Joi.string().pattern(/^\+?[0-9]{10,15}$/),
  address: Joi.string(),
  defaultLocation: Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
  }),
  isActive: Joi.boolean()
}).min(1)
  .messages({
    'object.min': 'Au moins un champ doit être mis à jour'
  });

// Schéma pour la connexion
export const loginSchema = Joi.object({
  email: Joi.string().email().required()
    .messages({
      'string.email': 'Format d\'email invalide',
      'any.required': 'Email est requis',
      'string.empty': 'Email ne peut pas être vide'
    }),
  password: Joi.string().required()
    .messages({
      'any.required': 'Mot de passe est requis',
      'string.empty': 'Mot de passe ne peut pas être vide'
    })
});

// Schéma pour le changement de mot de passe
export const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required()
    .messages({
      'any.required': 'Mot de passe actuel est requis',
      'string.empty': 'Mot de passe actuel ne peut pas être vide'
    }),
  newPassword: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
    .required()
    .messages({
      'string.pattern.base': 'Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial',
      'any.required': 'Nouveau mot de passe est requis',
      'string.empty': 'Nouveau mot de passe ne peut pas être vide'
    })
}).min(1);

// Schéma pour la réinitialisation du mot de passe
export const resetPasswordSchema = Joi.object({
  email: Joi.string().email().required()
    .messages({
      'string.email': 'Format d\'email invalide',
      'any.required': 'Email est requis',
      'string.empty': 'Email ne peut pas être vide'
    })
});

// Schéma pour la recherche d'utilisateurs
export const searchUsersSchema = Joi.object({
  role: Joi.string().valid(...Object.values(UserRole)),
  isActive: Joi.boolean(),
  search: Joi.string(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10)
});

// Schéma pour la mise à jour du rôle
export const updateRoleSchema = Joi.object({
  role: Joi.string().valid(...Object.values(UserRole)).required()
    .messages({
      'any.only': 'Rôle invalide',
      'any.required': 'Rôle est requis',
      'string.empty': 'Rôle ne peut pas être vide'
    })
});

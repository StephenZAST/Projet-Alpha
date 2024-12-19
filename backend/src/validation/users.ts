import Joi from 'joi';
import { UserRole } from '../models/user';

// Schéma pour la création d'un utilisateur
export const createUserSchema = Joi.object({
  email: Joi.string().email()
    .messages({
      'string.email': 'Format d\'email invalide',
      'string.empty': 'Email ne peut pas être vide'
    }),
  password: Joi.string()
    .min(6) // Reduced minimum length
    .messages({
      'string.min': 'Le mot de passe doit contenir au moins 6 caractères',
      'string.empty': 'Mot de passe ne peut pas être vide'
    }),
  firstName: Joi.string().allow('').optional(),
  lastName: Joi.string().allow('').optional(),
  phone: Joi.string().pattern(/^[0-9+\-\s]{8,}$/).optional() // More flexible pattern
    .messages({
      'string.pattern.base': 'Format de numéro de téléphone invalide'
    }),
  role: Joi.string().valid(...Object.values(UserRole))
    .default(UserRole.USER) // Add default role
    .messages({
      'any.only': 'Rôle invalide'
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

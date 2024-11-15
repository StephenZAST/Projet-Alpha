import Joi from 'joi';
import { UserRole } from '../models/user';

// Schéma pour la création d'un utilisateur
export const createUserSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
    .required()
    .messages({
      'string.pattern.base': 'Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial'
    }),
  firstName: Joi.string().required(),
  lastName: Joi.string().required(),
  phone: Joi.string().pattern(/^\+?[0-9]{10,15}$/).required(),
  role: Joi.string().valid(...Object.values(UserRole)).required(),
  address: Joi.string().required(),
  defaultLocation: Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
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
}).min(1);

// Schéma pour la connexion
export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

// Schéma pour le changement de mot de passe
export const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required(),
  newPassword: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
    .required()
    .messages({
      'string.pattern.base': 'Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial'
    })
}).min(1);

// Schéma pour la réinitialisation du mot de passe
export const resetPasswordSchema = Joi.object({
  email: Joi.string().email().required()
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
});

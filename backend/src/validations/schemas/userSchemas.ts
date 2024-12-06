import Joi from 'joi';
import { errorCodes } from '../../utils/errors';
import { UserRole, UserStatus, AccountCreationMethod } from '../../models/user';

const phoneRegex = /^\+?[1-9]\d{1,14}$/;
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

// Base address schema that can be reused
const addressSchema = Joi.object({
  street: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_ADDRESS,
      'string.empty': errorCodes.INVALID_ADDRESS
    }),
  city: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_ADDRESS,
      'string.empty': errorCodes.INVALID_ADDRESS
    }),
  postalCode: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_ADDRESS,
      'string.empty': errorCodes.INVALID_ADDRESS
    }),
  country: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_ADDRESS,
      'string.empty': errorCodes.INVALID_ADDRESS
    }),
  quartier: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_ADDRESS,
      'string.empty': errorCodes.INVALID_ADDRESS
    }),
  location: Joi.object({
    latitude: Joi.number().required()
      .messages({
        'any.required': errorCodes.INVALID_ADDRESS,
        'number.base': errorCodes.INVALID_ADDRESS
      }),
    longitude: Joi.number().required()
      .messages({
        'any.required': errorCodes.INVALID_ADDRESS,
        'number.base': errorCodes.INVALID_ADDRESS
      }),
    zoneId: Joi.string().required()
      .messages({
        'any.required': errorCodes.INVALID_ADDRESS,
        'string.empty': errorCodes.INVALID_ADDRESS
      })
  }).required(),
  additionalInfo: Joi.string()
});

// Base user schema that can be reused
const baseUserSchema = {
  email: Joi.string().email().required()
    .messages({
      'string.email': errorCodes.INVALID_EMAIL,
      'any.required': errorCodes.INVALID_EMAIL,
      'string.empty': errorCodes.INVALID_EMAIL
    }),
  displayName: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_USER_DATA,
      'string.empty': errorCodes.INVALID_USER_DATA
    }),
  phoneNumber: Joi.string().pattern(phoneRegex)
    .messages({
      'string.pattern.base': errorCodes.INVALID_PHONE
    }),
  address: addressSchema,
  language: Joi.string().valid('fr', 'en').default('fr'),
  avatar: Joi.string().uri()
    .messages({
      'string.uri': errorCodes.INVALID_IMAGE_URL
    })
};

// Customer registration schema
export const customerRegistrationSchema = Joi.object({
  ...baseUserSchema,
  password: Joi.string().pattern(passwordRegex).required()
    .messages({
      'string.pattern.base': errorCodes.INVALID_PASSWORD,
      'any.required': errorCodes.INVALID_PASSWORD,
      'string.empty': errorCodes.INVALID_PASSWORD
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
  createdBy: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_ADMIN_ID,
      'string.empty': errorCodes.INVALID_ADMIN_ID
    })
});

// Password related schemas
export const passwordResetRequestSchema = Joi.object({
  email: Joi.string().email().required()
    .messages({
      'string.email': errorCodes.INVALID_EMAIL,
      'any.required': errorCodes.INVALID_EMAIL,
      'string.empty': errorCodes.INVALID_EMAIL
    })
});

export const passwordResetSchema = Joi.object({
  token: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_RESET_TOKEN,
      'string.empty': errorCodes.INVALID_RESET_TOKEN
    }),
  newPassword: Joi.string().pattern(passwordRegex).required()
    .messages({
      'string.pattern.base': errorCodes.INVALID_PASSWORD,
      'any.required': errorCodes.INVALID_PASSWORD,
      'string.empty': errorCodes.INVALID_PASSWORD
    })
});

// Email verification schema
export const emailVerificationSchema = Joi.object({
  token: Joi.string().required()
    .messages({
      'any.required': errorCodes.INVALID_VERIFICATION_TOKEN,
      'string.empty': errorCodes.INVALID_VERIFICATION_TOKEN
    })
});

// Profile update schemas
export const updateProfileSchema = Joi.object({
  displayName: Joi.string().min(2)
    .messages({
      'string.min': errorCodes.INVALID_USER_DATA
    }),
  phoneNumber: Joi.string().pattern(phoneRegex)
    .messages({
      'string.pattern.base': errorCodes.INVALID_PHONE
    }),
  email: Joi.string().email()
    .messages({
      'string.email': errorCodes.INVALID_EMAIL
    }),
  avatar: Joi.string().uri()
    .messages({
      'string.uri': errorCodes.INVALID_IMAGE_URL
    }),
  language: Joi.string().valid('fr', 'en')
    .messages({
      'any.only': errorCodes.INVALID_LANGUAGE
    })
}).min(1).messages({
  'object.min': errorCodes.VALIDATION_ERROR
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

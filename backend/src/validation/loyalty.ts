import Joi from 'joi';

export const redeemRewardSchema = Joi.object({
  shippingAddress: Joi.object({
    street: Joi.string().required(),
    city: Joi.string().required(),
    state: Joi.string().required(),
    zipCode: Joi.string().required(),
    country: Joi.string().required(),
    phoneNumber: Joi.string().required()
  }).when('rewardType', {
    is: 'physical',
    then: Joi.required(),
    otherwise: Joi.forbidden()
  })
});

export const createRewardSchema = Joi.object({
  name: Joi.string().required(),
  description: Joi.string().required(),
  type: Joi.string().valid('physical', 'digital', 'discount').required(),
  category: Joi.string().required(),
  pointsCost: Joi.number().integer().min(0).required(),
  quantity: Joi.number().integer().min(-1).required(), // -1 for unlimited
  startDate: Joi.date().iso().required(),
  endDate: Joi.date().iso().greater(Joi.ref('startDate')),
  tier: Joi.string().valid('bronze', 'silver', 'gold', 'platinum'),
  metadata: Joi.object({
    discountPercentage: Joi.when('type', {
      is: 'discount',
      then: Joi.number().min(0).max(100).required(),
      otherwise: Joi.forbidden()
    }),
    digitalCode: Joi.when('type', {
      is: 'digital',
      then: Joi.string(),
      otherwise: Joi.forbidden()
    }),
    shippingWeight: Joi.when('type', {
      is: 'physical',
      then: Joi.number().min(0),
      otherwise: Joi.forbidden()
    })
  }).required()
});

export const updateLoyaltyTierSchema = Joi.object({
  name: Joi.string(),
  description: Joi.string(),
  pointsThreshold: Joi.number().integer().min(0),
  benefits: Joi.array().items(
    Joi.object({
      type: Joi.string().valid('discount', 'freeShipping', 'pointsMultiplier', 'exclusiveAccess').required(),
      value: Joi.alternatives().conditional('type', {
        switch: [
          {
            is: 'discount',
            then: Joi.number().min(0).max(100).required()
          },
          {
            is: 'pointsMultiplier',
            then: Joi.number().min(1).required()
          },
          {
            is: 'freeShipping',
            then: Joi.boolean().required()
          },
          {
            is: 'exclusiveAccess',
            then: Joi.boolean().required()
          }
        ]
      })
    })
  ),
  icon: Joi.string().uri(),
  color: Joi.string().pattern(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/),
  status: Joi.string().valid('active', 'inactive')
});

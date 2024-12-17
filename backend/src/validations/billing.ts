import Joi from 'joi';

export const createBillSchema = Joi.object({
  userId: Joi.string().required(),
  amount: Joi.number().required(),
  dueDate: Joi.date().required(),
  status: Joi.string().valid('pending', 'paid', 'overdue').default('pending'),
  items: Joi.array().items(
    Joi.object({
      name: Joi.string().required(),
      quantity: Joi.number().required(),
      price: Joi.number().required(),
    })
  ),
  notes: Joi.string().optional(),
});

export const updateBillSchema = Joi.object({
  amount: Joi.number().optional(),
  dueDate: Joi.date().optional(),
  status: Joi.string().valid('pending', 'paid', 'overdue').optional(),
  items: Joi.array().items(
    Joi.object({
      name: Joi.string().required(),
      quantity: Joi.number().required(),
      price: Joi.number().required(),
    })
  ).optional(),
  notes: Joi.string().optional(),
});

export const getBillsSchema = Joi.object({
  page: Joi.number().integer().min(1),
  limit: Joi.number().integer().min(1).max(100),
  status: Joi.string().valid('pending', 'paid', 'overdue'),
});

export const getBillByIdSchema = Joi.object({
  id: Joi.string().required(),
});

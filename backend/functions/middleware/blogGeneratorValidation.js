const Joi = require('joi');

const blogGenerationConfigSchema = Joi.object({
    topic: Joi.string().required().min(10).max(200)
        .messages({
            'string.empty': 'Le sujet est requis',
            'string.min': 'Le sujet doit contenir au moins 10 caractères',
            'string.max': 'Le sujet ne doit pas dépasser 200 caractères'
        }),
    
    tone: Joi.string().valid('professional', 'casual', 'educational').required()
        .messages({
            'any.required': 'Le ton est requis',
            'any.only': 'Le ton doit être professional, casual ou educational'
        }),
    
    targetLength: Joi.string().valid('short', 'medium', 'long').required()
        .messages({
            'any.required': 'La longueur cible est requise',
            'any.only': 'La longueur doit être short, medium ou long'
        }),
    
    keywords: Joi.array().items(Joi.string()).min(1).max(10).required()
        .messages({
            'array.min': 'Au moins un mot-clé est requis',
            'array.max': 'Maximum 10 mots-clés autorisés'
        }),
    
    targetAudience: Joi.string().required().max(100)
        .messages({
            'string.empty': 'Le public cible est requis',
            'string.max': 'Le public cible ne doit pas dépasser 100 caractères'
        }),
    
    includeCallToAction: Joi.boolean().required()
        .messages({
            'any.required': "L'inclusion d'un appel à l'action doit être spécifiée"
        })
});

const googleAIKeySchema = Joi.object({
    googleAIKey: Joi.string().required().min(20)
        .messages({
            'string.empty': 'La clé API Google AI est requise',
            'string.min': 'La clé API semble invalide (trop courte)'
        })
});

module.exports = {
    validateBlogGenerationConfig: (req, res, next) => {
        const { error } = blogGenerationConfigSchema.validate(req.body, { abortEarly: false });
        
        if (error) {
            const errors = error.details.map(detail => detail.message);
            return res.status(400).json({
                error: 'Validation échouée',
                details: errors
            });
        }
        
        next();
    },

    validateGoogleAIKey: (req, res, next) => {
        const { error } = googleAIKeySchema.validate(req.body, { abortEarly: false });
        
        if (error) {
            const errors = error.details.map(detail => detail.message);
            return res.status(400).json({
                error: 'Validation de la clé API échouée',
                details: errors
            });
        }
        
        next();
    }
};

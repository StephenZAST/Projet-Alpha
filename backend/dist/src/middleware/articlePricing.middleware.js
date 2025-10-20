"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateArticlePricing = void 0;
const pricing_config_1 = require("../config/pricing.config");
const validateArticlePricing = (req, res, next) => {
    const { base_price, premium_price, price_per_kg, service_type_id } = req.body;
    try {
        // Validation du prix de base
        if (!base_price && !price_per_kg) {
            throw new Error("Au moins un type de prix (base_price ou price_per_kg) doit être défini");
        }
        if (base_price && base_price < pricing_config_1.pricingConfig.minBasePrice) {
            throw new Error(`Le prix de base doit être supérieur à ${pricing_config_1.pricingConfig.minBasePrice}`);
        }
        // Validation du prix premium
        if (premium_price) {
            if (!pricing_config_1.pricingConfig.allowPremiumPrices) {
                throw new Error("Les prix premium ne sont pas activés dans la configuration");
            }
            if (premium_price <= base_price) {
                throw new Error("Le prix premium doit être supérieur au prix de base");
            }
            if (premium_price > base_price * pricing_config_1.pricingConfig.maxPremiumMultiplier) {
                throw new Error(`Le prix premium ne peut pas dépasser ${pricing_config_1.pricingConfig.maxPremiumMultiplier}x le prix de base`);
            }
        }
        // Validation du prix au kilo
        if (price_per_kg && !pricing_config_1.pricingConfig.allowPricePerKg) {
            throw new Error("Les prix au kilo ne sont pas activés dans la configuration");
        }
        next();
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};
exports.validateArticlePricing = validateArticlePricing;

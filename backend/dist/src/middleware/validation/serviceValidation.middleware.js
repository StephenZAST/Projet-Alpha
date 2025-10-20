"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateServiceCompatibility = exports.validateWeightPricing = exports.validateServiceTypeCreate = void 0;
const validators_1 = require("../../utils/validators");
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const validateServiceTypeCreate = (req, res, next) => {
    const { name, description } = req.body;
    if (!name || typeof name !== 'string' || name.length < 2) {
        return res.status(400).json({
            success: false,
            message: 'Le nom du service doit contenir au moins 2 caractères'
        });
    }
    if (description && typeof description !== 'string') {
        return res.status(400).json({
            success: false,
            message: 'La description doit être une chaîne de caractères'
        });
    }
    next();
};
exports.validateServiceTypeCreate = validateServiceTypeCreate;
const validateWeightPricing = (req, res, next) => {
    const { service_type_id, min_weight, max_weight, price_per_kg } = req.body;
    if (!(0, validators_1.validateUUID)(service_type_id)) {
        return res.status(400).json({
            success: false,
            message: 'ID de type de service invalide'
        });
    }
    if (!min_weight || !max_weight || !price_per_kg) {
        return res.status(400).json({
            success: false,
            message: 'Tous les champs de tarification sont requis'
        });
    }
    if (min_weight >= max_weight) {
        return res.status(400).json({
            success: false,
            message: 'Le poids minimum doit être inférieur au poids maximum'
        });
    }
    if (price_per_kg <= 0) {
        return res.status(400).json({
            success: false,
            message: 'Le prix par kg doit être supérieur à 0'
        });
    }
    next();
};
exports.validateWeightPricing = validateWeightPricing;
const validateServiceCompatibility = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const { article_id, service_id } = req.body;
    if (!(0, validators_1.validateUUID)(article_id) || !(0, validators_1.validateUUID)(service_id)) {
        return res.status(400).json({
            success: false,
            message: 'IDs invalides'
        });
    }
    // Vérification centralisée de la compatibilité
    try {
        const compatibility = yield prisma.article_service_prices.findFirst({
            where: {
                article_id,
                service_id,
                is_available: true
            }
        });
        if (!compatibility) {
            return res.status(400).json({
                success: false,
                message: 'Service non compatible avec cet article'
            });
        }
        next();
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: 'Erreur lors de la vérification de compatibilité',
            error: error instanceof Error ? error.message : error
        });
    }
});
exports.validateServiceCompatibility = validateServiceCompatibility;

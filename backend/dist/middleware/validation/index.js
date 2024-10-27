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
exports.validateArticleInput = void 0;
const articleValidation_1 = require("./articleValidation");
const errors_1 = require("../../utils/errors");
const validateArticleInput = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const validatedData = yield articleValidation_1.articleValidationSchema.validateAsync(req.body);
        // Type-safe price validation
        const prices = validatedData.prices;
        Object.entries(prices).forEach(([service, servicePrice]) => {
            Object.values(servicePrice).forEach(price => {
                if (!(0, articleValidation_1.priceRangeValidation)(price, service)) {
                    throw new errors_1.AppError(400, `Invalid price range for service: ${service}`, errors_1.errorCodes.INVALID_PRICE_RANGE);
                }
            });
        });
        // Validate service availability
        validatedData.availableServices.forEach((service) => {
            if (!prices[service]) {
                throw new errors_1.AppError(400, `Price must be set for available service: ${service}`, errors_1.errorCodes.INVALID_SERVICE);
            }
        });
        req.body = validatedData;
        next();
    }
    catch (error) {
        next(error);
    }
});
exports.validateArticleInput = validateArticleInput;

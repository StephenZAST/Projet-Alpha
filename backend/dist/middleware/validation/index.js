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
        // Validate price ranges for each service (crucial: add price range validation logic)
        Object.entries(validatedData.prices).forEach(([service, prices]) => {
            Object.values(prices).forEach(price => {
                // Placeholder - Replace with your actual price range validation logic
                if (price < 0 || price > 100) { // Example - replace with your actual validation
                    throw new errors_1.AppError(400, `Invalid price range for service: ${service}`, errors_1.errorCodes.INVALID_PRICE_RANGE);
                }
            });
        });
        next();
    }
    catch (error) {
        next(error);
    }
});
exports.validateArticleInput = validateArticleInput;

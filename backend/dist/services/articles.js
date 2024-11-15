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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createArticle = createArticle;
exports.getArticles = getArticles;
exports.updateArticle = updateArticle;
exports.deleteArticle = deleteArticle;
const firebase_1 = require("./firebase");
const errors_1 = require("../utils/errors");
const joi_1 = __importDefault(require("joi"));
const order_1 = require("../models/order");
const articleValidationSchema = joi_1.default.object({
    articleName: joi_1.default.string().required(),
    articleCategory: joi_1.default.string().required(),
    prices: joi_1.default.object().required().pattern(joi_1.default.string().valid(...Object.values(order_1.MainService)), joi_1.default.object().pattern(joi_1.default.string().valid(...Object.values(order_1.PriceType)), joi_1.default.number().min(0))),
    availableServices: joi_1.default.array().items(joi_1.default.string().valid(...Object.values(order_1.MainService))).required(),
    availableAdditionalServices: joi_1.default.array().items(joi_1.default.string()).required()
});
function createArticle(articleData) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const validationResult = articleValidationSchema.validate(articleData);
            if (validationResult.error) {
                const errorMessage = validationResult.error.details[0].message;
                throw new errors_1.AppError(400, errorMessage, errors_1.errorCodes.INVALID_ARTICLE_DATA);
            }
            const articleRef = yield firebase_1.db.collection('articles').add(articleData);
            return Object.assign(Object.assign({}, articleData), { articleId: articleRef.id });
        }
        catch (error) {
            if (error instanceof errors_1.AppError) {
                return null;
            }
            throw new errors_1.AppError(500, 'Failed to create article', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
function getArticles() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const articlesSnapshot = yield firebase_1.db.collection('articles').get();
            return articlesSnapshot.docs.map((doc) => (Object.assign({ articleId: doc.id }, doc.data())));
        }
        catch (error) {
            if (error instanceof errors_1.AppError) {
                throw error;
            }
            else {
                throw new errors_1.AppError(500, 'Failed to fetch articles', errors_1.errorCodes.DATABASE_ERROR);
            }
        }
    });
}
function updateArticle(articleId, articleData) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const articleRef = firebase_1.db.collection('articles').doc(articleId);
            const article = yield articleRef.get();
            if (!article.exists) {
                throw new errors_1.AppError(404, 'Article not found', errors_1.errorCodes.ARTICLE_NOT_FOUND);
            }
            yield articleRef.update(articleData);
            return Object.assign(Object.assign({ articleId }, article.data()), articleData);
        }
        catch (error) {
            if (error instanceof errors_1.AppError)
                throw error;
            throw new errors_1.AppError(500, 'Failed to update article', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
function deleteArticle(articleId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const articleRef = firebase_1.db.collection('articles').doc(articleId);
            const article = yield articleRef.get();
            if (!article.exists) {
                throw new errors_1.AppError(404, 'Article not found', errors_1.errorCodes.ARTICLE_NOT_FOUND);
            }
            yield articleRef.delete();
            return true;
        }
        catch (error) {
            if (error instanceof errors_1.AppError)
                throw error;
            throw new errors_1.AppError(500, 'Failed to delete article', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}

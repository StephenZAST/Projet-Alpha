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
exports.deleteCategory = exports.updateCategory = exports.createCategory = exports.getCategories = void 0;
const firebase_1 = require("./firebase");
const errors_1 = require("../utils/errors");
function getCategories() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const categoriesSnapshot = yield firebase_1.db.collection('categories').get();
            return categoriesSnapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to fetch categories', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.getCategories = getCategories;
function createCategory(categoryData) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const categoryRef = yield firebase_1.db.collection('categories').add(categoryData);
            return Object.assign(Object.assign({}, categoryData), { id: categoryRef.id });
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to create category', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.createCategory = createCategory;
function updateCategory(categoryId, categoryData) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const categoryRef = firebase_1.db.collection('categories').doc(categoryId);
            yield categoryRef.update(categoryData);
            const updatedCategory = yield categoryRef.get();
            return Object.assign({ id: categoryId }, updatedCategory.data());
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to update category', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.updateCategory = updateCategory;
function deleteCategory(categoryId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield firebase_1.db.collection('categories').doc(categoryId).delete();
        }
        catch (error) {
            throw new errors_1.AppError(500, 'Failed to delete category', errors_1.errorCodes.DATABASE_ERROR);
        }
    });
}
exports.deleteCategory = deleteCategory;

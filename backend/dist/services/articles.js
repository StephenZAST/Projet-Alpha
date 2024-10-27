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
exports.getArticles = exports.createArticle = void 0;
const firebase_1 = require("./firebase");
function createArticle(article) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const articleRef = yield firebase_1.db.collection('articles').add(article);
            return Object.assign(Object.assign({}, article), { articleId: articleRef.id });
        }
        catch (error) {
            console.error('Error creating article:', error);
            return null;
        }
    });
}
exports.createArticle = createArticle;
function getArticles() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const articlesSnapshot = yield firebase_1.db.collection('articles').get();
            return articlesSnapshot.docs.map(doc => (Object.assign({ articleId: doc.id }, doc.data())));
        }
        catch (error) {
            console.error('Error fetching articles:', error);
            return [];
        }
    });
}
exports.getArticles = getArticles;

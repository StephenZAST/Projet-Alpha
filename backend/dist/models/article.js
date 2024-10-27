"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PriceType = exports.MainService = exports.ArticleCategory = void 0;
const order_1 = require("./order");
Object.defineProperty(exports, "MainService", { enumerable: true, get: function () { return order_1.MainService; } });
Object.defineProperty(exports, "PriceType", { enumerable: true, get: function () { return order_1.PriceType; } });
var ArticleCategory;
(function (ArticleCategory) {
    ArticleCategory["CHEMISIER"] = "Chemisier";
    ArticleCategory["PANTALON"] = "Pantalon";
    ArticleCategory["JUPE"] = "Jupe";
    ArticleCategory["COSTUME"] = "Costume";
    ArticleCategory["BAZIN_COMPLET"] = "Bazin/Complet";
    ArticleCategory["TRADITIONNEL"] = "Traditionnel";
    ArticleCategory["ENFANTS"] = "Enfants";
    ArticleCategory["SPORT"] = "Sport";
    ArticleCategory["LINGE_MAISON"] = "Linge de maison";
    ArticleCategory["ACCESSOIRES"] = "Accessoires / autres";
})(ArticleCategory || (exports.ArticleCategory = ArticleCategory = {}));

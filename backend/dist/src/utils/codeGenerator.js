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
exports.generateAffiliateCode = generateAffiliateCode;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
function generateAffiliateCode() {
    return __awaiter(this, arguments, void 0, function* (length = 8) {
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let code;
        let isUnique = false;
        while (!isUnique) {
            code = '';
            for (let i = 0; i < length; i++) {
                code += characters.charAt(Math.floor(Math.random() * characters.length));
            }
            // Vérifier que le code n'existe pas déjà
            const existingCode = yield prisma.affiliate_profiles.findFirst({
                where: { affiliate_code: code }
            });
            if (!existingCode) {
                isUnique = true;
                return code;
            }
        }
        throw new Error('Unable to generate unique code');
    });
}

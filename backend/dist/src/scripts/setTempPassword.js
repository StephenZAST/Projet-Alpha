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
const client_1 = require("@prisma/client");
const bcrypt_1 = __importDefault(require("bcrypt"));
/**
 * CLI to set a temporary password for a user (hashes with bcrypt before saving).
 * Usage:
 *   ts-node src/scripts/setTempPassword.ts --id <user-id> --password myPlain
 *   ts-node src/scripts/setTempPassword.ts --id <user-id> --generate
 */
const prisma = new client_1.PrismaClient();
function getArgValue(name) {
    const idx = process.argv.indexOf(`--${name}`);
    if (idx === -1)
        return undefined;
    return process.argv[idx + 1];
}
function generateRandomPassword(length = 12) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=';
    let out = '';
    for (let i = 0; i < length; i++)
        out += chars[Math.floor(Math.random() * chars.length)];
    return out;
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        const id = getArgValue('id');
        const password = getArgValue('password');
        const gen = process.argv.includes('--generate');
        if (!id) {
            console.error('Please provide --id <user-id>');
            process.exit(2);
        }
        if (!password && !gen) {
            console.error('Provide --password <plain> or --generate');
            process.exit(2);
        }
        const plain = password || generateRandomPassword();
        try {
            const user = yield prisma.users.findUnique({ where: { id } });
            if (!user) {
                console.error('User not found');
                process.exit(1);
            }
            const saltRounds = 10;
            const hash = yield bcrypt_1.default.hash(plain, saltRounds);
            yield prisma.users.update({ where: { id }, data: { password: hash } });
            console.log('Temporary password set for user:');
            console.log('user id:', id);
            console.log('plain password (show only once):', plain);
            console.log('Please communicate it securely and encourage password reset by the user.');
        }
        catch (err) {
            console.error('Error:', err.message || err);
            process.exit(1);
        }
        finally {
            yield prisma.$disconnect();
        }
    });
}
main();

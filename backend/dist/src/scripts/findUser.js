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
const client_1 = require("@prisma/client");
/**
 * Small CLI to lookup a user by id, email or phone and print identifying information.
 * Usage:
 *   ts-node src/scripts/findUser.ts --id <user-id>
 *   ts-node src/scripts/findUser.ts --email user@example.com
 *   ts-node src/scripts/findUser.ts --phone "+123456789"
 */
const prisma = new client_1.PrismaClient();
function getArgValue(name) {
    const idx = process.argv.indexOf(`--${name}`);
    if (idx === -1)
        return undefined;
    return process.argv[idx + 1];
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        const id = getArgValue('id');
        const email = getArgValue('email');
        const phone = getArgValue('phone');
        if (!id && !email && !phone) {
            console.error('Please provide --id or --email or --phone');
            process.exit(2);
        }
        try {
            let user = null;
            if (id) {
                user = yield prisma.users.findUnique({ where: { id } });
            }
            else if (email) {
                user = yield prisma.users.findFirst({ where: { email } });
            }
            else if (phone) {
                user = yield prisma.users.findFirst({ where: { phone } });
            }
            if (!user) {
                console.log('No user found');
                process.exit(0);
            }
            // Print safe identifying information only
            const safe = {
                id: user.id,
                email: user.email,
                phone: user.phone,
                firstName: user.first_name || null,
                lastName: user.last_name || null,
                role: user.role || null,
                created_at: user.created_at || null,
            };
            console.log(JSON.stringify(safe, null, 2));
        }
        catch (err) {
            console.error('Error querying user:', err.message || err);
            process.exit(1);
        }
        finally {
            yield prisma.$disconnect();
        }
    });
}
main();

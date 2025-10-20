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
const crypto_1 = __importDefault(require("crypto"));
const prisma = new client_1.PrismaClient();
function getArgValue(name) {
    const idx = process.argv.indexOf(`--${name}`);
    if (idx === -1)
        return undefined;
    return process.argv[idx + 1];
}
function generateAffiliateCode(length = 8) {
    return crypto_1.default.randomBytes(Math.ceil(length / 2)).toString('hex').slice(0, length).toUpperCase();
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        const userId = getArgValue('id');
        const doShow = process.argv.includes('--show');
        const doCreate = process.argv.includes('--create');
        if (!userId) {
            console.error('Please provide --id <userId>');
            process.exit(2);
        }
        try {
            const profile = yield prisma.affiliate_profiles.findUnique({ where: { userId } });
            if (doShow) {
                if (!profile) {
                    console.log('No affiliate profile found for user:', userId);
                    process.exit(0);
                }
                console.log(JSON.stringify(profile, null, 2));
                process.exit(0);
            }
            if (doCreate) {
                if (profile) {
                    console.log('Affiliate profile already exists for user:', userId);
                    console.log(JSON.stringify(profile, null, 2));
                    process.exit(0);
                }
                // generate unique affiliate_code - try a few times
                let code = generateAffiliateCode(8);
                let attempt = 0;
                while (attempt < 5) {
                    const existing = yield prisma.affiliate_profiles.findFirst({ where: { affiliate_code: code } });
                    if (!existing)
                        break;
                    code = generateAffiliateCode(8);
                    attempt++;
                }
                const newProfile = yield prisma.affiliate_profiles.create({
                    data: {
                        userId,
                        affiliate_code: code,
                        parent_affiliate_id: null,
                        commission_balance: 0,
                        total_earned: 0,
                        commission_rate: 10.0,
                        is_active: true,
                        total_referrals: 0,
                        monthly_earnings: 0.0,
                        level_id: null,
                        status: 'PENDING',
                    },
                });
                console.log('Created affiliate profile:');
                console.log(JSON.stringify(newProfile, null, 2));
                process.exit(0);
            }
            console.log('No action specified. Use --show or --create');
            process.exit(2);
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

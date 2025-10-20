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
 * Script to find "orphaned" affiliate_profiles whose userId no longer exists in users.
 * Options:
 *   --list          : list orphaned affiliate_profiles
 *   --delete        : delete orphaned affiliate_profiles (destructive)
 *   --reassign <id> : reassign orphaned profiles to an existing user id (careful)
 *   --dry           : run in dry mode (no deletion/reassign)
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
        const doList = process.argv.includes('--list');
        const doDelete = process.argv.includes('--delete');
        const reassignTo = getArgValue('reassign');
        const dry = process.argv.includes('--dry');
        if (!doList && !doDelete && !reassignTo) {
            console.error('Specify an action: --list, --delete or --reassign <userId>');
            process.exit(2);
        }
        try {
            // Find affiliate profiles where userId not in users
            const orphans = yield prisma.$queryRaw `
      SELECT ap.* FROM affiliate_profiles ap
      LEFT JOIN users u ON ap."userId" = u.id
      WHERE u.id IS NULL
    `;
            if (orphans.length === 0) {
                console.log('No orphaned affiliate_profiles found.');
                process.exit(0);
            }
            console.log(`Found ${orphans.length} orphaned affiliate_profiles`);
            if (doList) {
                console.log(JSON.stringify(orphans, null, 2));
            }
            if (doDelete) {
                if (dry) {
                    console.log('--dry mode: no deletion performed.');
                }
                else {
                    const ids = orphans.map(o => o.id);
                    console.log('Deleting profiles:', ids);
                    yield prisma.affiliate_profiles.deleteMany({ where: { id: { in: ids } } });
                    console.log('Deleted.');
                }
            }
            if (reassignTo) {
                // verify destination user exists
                const dest = yield prisma.users.findUnique({ where: { id: reassignTo } });
                if (!dest) {
                    console.error('Destination user does not exist:', reassignTo);
                    process.exit(1);
                }
                if (dry) {
                    console.log('--dry mode: no reassignment performed.');
                    console.log('Would reassign the following profiles to user:', reassignTo);
                    console.log(orphans.map(o => o.id));
                }
                else {
                    for (const o of orphans) {
                        // reassign by creating a new profile for destination user OR appending data
                        // If destination user already has a profile, skip and log
                        const exists = yield prisma.affiliate_profiles.findUnique({ where: { userId: reassignTo } });
                        if (exists) {
                            console.log('Destination user already has an affiliate profile, skipping:', reassignTo);
                            break;
                        }
                        // Update orphan profile's userId to destination
                        yield prisma.affiliate_profiles.update({ where: { id: o.id }, data: { userId: reassignTo } });
                        console.log(`Reassigned profile ${o.id} -> user ${reassignTo}`);
                    }
                }
            }
            process.exit(0);
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

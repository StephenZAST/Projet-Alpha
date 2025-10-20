"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
// Test de connexion
prisma.$connect()
    .then(() => {
    console.log('Database connection successful');
})
    .catch((error) => {
    console.error('Database connection error:', error);
});
exports.default = prisma;

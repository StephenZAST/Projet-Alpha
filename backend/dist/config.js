"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.config = void 0;
exports.config = {
    port: 3001,
    allowedOrigins: process.env.ALLOWED_ORIGINS || ['http://localhost:3000']
};

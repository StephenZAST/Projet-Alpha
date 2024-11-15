"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const user_1 = require("../../../models/user");
const globals_1 = require("@jest/globals");
(0, globals_1.describe)('User Model', () => {
    const mockUserData = {
        uid: '12345',
        email: 'test@example.com',
        displayName: 'John Doe',
        phoneNumber: '+1234567890',
        role: user_1.UserRole.CLIENT,
        creationDate: new Date(),
        lastLogin: new Date(),
        address: {
            street: '123 Test St',
            city: 'Test City',
            country: 'Test Country',
            postalCode: '12345'
        }
    };
    (0, globals_1.it)('should validate user data structure', () => {
        const user = Object.assign({}, mockUserData);
        (0, globals_1.expect)(user).toBeDefined();
        (0, globals_1.expect)(user.email).toBe(mockUserData.email);
        (0, globals_1.expect)(user.displayName).toBe(mockUserData.displayName);
        (0, globals_1.expect)(user.role).toBe(user_1.UserRole.CLIENT);
    });
    (0, globals_1.it)('should validate email format', () => {
        const invalidUserData = Object.assign(Object.assign({}, mockUserData), { email: 'invalid-email' });
        (0, globals_1.expect)(invalidUserData.email).not.toMatch(/^[^\s@]+@[^\s@]+\.[^\s@]+$/);
    });
});

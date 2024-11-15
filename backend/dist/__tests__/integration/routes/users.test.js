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
const supertest_1 = __importDefault(require("supertest"));
const express_1 = __importDefault(require("express"));
const users_1 = __importDefault(require("../../../routes/users"));
const app = (0, express_1.default)();
app.use(express_1.default.json());
app.use('/api/users', users_1.default);
describe('Users API', () => {
    const mockUser = {
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        address: {
            street: '123 Test St',
            city: 'Test City',
            country: 'Test Country',
            postalCode: '12345'
        }
    };
    describe('POST /api/users', () => {
        it('should create a new user', () => __awaiter(void 0, void 0, void 0, function* () {
            const response = yield (0, supertest_1.default)(app)
                .post('/api/users')
                .send(mockUser);
            expect(response.status).toBe(201);
            expect(response.body).toHaveProperty('id');
            expect(response.body.email).toBe(mockUser.email);
        }));
        it('should return 400 for invalid user data', () => __awaiter(void 0, void 0, void 0, function* () {
            const invalidUser = Object.assign(Object.assign({}, mockUser), { email: 'invalid-email' });
            const response = yield (0, supertest_1.default)(app)
                .post('/api/users')
                .send(invalidUser);
            expect(response.status).toBe(400);
        }));
    });
    describe('GET /api/users/:id', () => {
        it('should get user by id', () => __awaiter(void 0, void 0, void 0, function* () {
            // Créer d'abord un utilisateur
            const createResponse = yield (0, supertest_1.default)(app)
                .post('/api/users')
                .send(mockUser);
            const userId = createResponse.body.id;
            // Récupérer l'utilisateur créé
            const getResponse = yield (0, supertest_1.default)(app)
                .get(`/api/users/${userId}`);
            expect(getResponse.status).toBe(200);
            expect(getResponse.body.id).toBe(userId);
            expect(getResponse.body.email).toBe(mockUser.email);
        }));
        it('should return 404 for non-existent user', () => __awaiter(void 0, void 0, void 0, function* () {
            const response = yield (0, supertest_1.default)(app)
                .get('/api/users/non-existent-id');
            expect(response.status).toBe(404);
        }));
    });
});

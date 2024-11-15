"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Définir l'environnement de test
process.env.NODE_ENV = 'test';
// Timeout global pour les tests
jest.setTimeout(30000);
// Nettoyage après chaque test
afterEach(() => {
    jest.clearAllMocks();
});

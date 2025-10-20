"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    setupFilesAfterEnv: ['./tests/setup.ts'],
    transform: {
        '^.+\\.tsx?$': ['ts-jest', {
                tsconfig: 'tsconfig.json'
            }]
    },
    moduleNameMapper: {
        '^@/(.*)$': '<rootDir>/src/$1'
    },
    testMatch: ['**/*.test.ts'],
    globals: {
        'ts-jest': {
            isolatedModules: true
        }
    },
    setupFiles: ['<rootDir>/tests/jest.setup.ts']
};
exports.default = config;

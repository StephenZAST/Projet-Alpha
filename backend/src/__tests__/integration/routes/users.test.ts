// import request from 'supertest';
// import express from 'express';
// import usersRouter from '../../../routes/users';
// import { describe, it } from 'node:test';

// const app = express();
// app.use(express.json());
// app.use('/api/users', usersRouter);

// describe('Users API', () => {
//   const mockUser = {
//     email: 'test@example.com',
//     firstName: 'John',
//     lastName: 'Doe',
//     phoneNumber: '+1234567890',
//     address: {
//       street: '123 Test St',
//       city: 'Test City',
//       country: 'Test Country',
//       postalCode: '12345'
//     }
//   };

//   describe('POST /api/users', () => {
//     it('should create a new user', async () => {
//       const response = await request(app)
//         .post('/api/users')
//         .send(mockUser);

//       expect(response.status).toBe(201);
//       expect(response.body).toHaveProperty('id');
//       expect(response.body.email).toBe(mockUser.email);
//     });

//     it('should return 400 for invalid user data', async () => {
//       const invalidUser = { ...mockUser, email: 'invalid-email' };
//       const response = await request(app)
//         .post('/api/users')
//         .send(invalidUser);

//       expect(response.status).toBe(400);
//     });
//   });

//   describe('GET /api/users/:id', () => {
//     it('should get user by id', async () => {
//       // Créer d'abord un utilisateur
//       const createResponse = await request(app)
//         .post('/api/users')
//         .send(mockUser);
      
//       const userId = createResponse.body.id;

//       // Récupérer l'utilisateur créé
//       const getResponse = await request(app)
//         .get(`/api/users/${userId}`);

//       expect(getResponse.status).toBe(200);
//       expect(getResponse.body.id).toBe(userId);
//       expect(getResponse.body.email).toBe(mockUser.email);
//     });

//     it('should return 404 for non-existent user', async () => {
//       const response = await request(app)
//         .get('/api/users/non-existent-id');

//       expect(response.status).toBe(404);
//     });
//   });
// });
// function expect(status: number) {
//   throw new Error('Function not implemented.');
// }


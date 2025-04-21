import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Test de connexion
prisma.$connect()
  .then(() => {
    console.log('Database connection successful');
  })
  .catch((error) => {
    console.error('Database connection error:', error);
  });

export default prisma;

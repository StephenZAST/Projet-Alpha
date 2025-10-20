import app, { prisma } from './app';
import './scheduler'; // start scheduled tasks only for the long-running server

const PORT = process.env.PORT || 3001;

async function start() {
  try {
    await prisma.$connect();
    console.log('Successfully connected to the database');

    process.on('beforeExit', async () => {
      await prisma.$disconnect();
    });

    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();

export default start;

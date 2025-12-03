/**
 * 📝 Script pour insérer les articles pilotes
 * Usage: npm run seed:blog
 */

import { PrismaClient } from '@prisma/client';
import { seedBlogArticles } from '../seeds/blogArticles.seed';

const prisma = new PrismaClient();

async function main() {
  try {
    console.log('🌱 Démarrage du seed des articles de blog...');
    
    await seedBlogArticles(prisma);
    
    console.log('✅ Seed complété avec succès');
  } catch (error) {
    console.error('❌ Erreur lors du seed:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main();

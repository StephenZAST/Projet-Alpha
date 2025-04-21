import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function generateAffiliateCode(length: number = 8): Promise<string> {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code: string;
  let isUnique = false;

  while (!isUnique) {
    code = '';
    for (let i = 0; i < length; i++) {
      code += characters.charAt(Math.floor(Math.random() * characters.length));
    }

    // Vérifier que le code n'existe pas déjà
    const existingCode = await prisma.affiliate_profiles.findFirst({
      where: { affiliate_code: code }
    });

    if (!existingCode) {
      isUnique = true;
      return code;
    }
  }

  throw new Error('Unable to generate unique code');
}

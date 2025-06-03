import { Request, Response } from 'express';
import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export class UserController {
  static async searchUsers(req: Request, res: Response) {
    try {
      const {
        query = '',
        filter = 'name',
        page = 1,
        limit = 10,
      } = req.query;

      // Construire la condition de recherche avec le bon typage
      let searchCondition: Prisma.usersWhereInput = {
        role: 'CLIENT',
      };

      // Construire la condition de recherche en fonction du filtre
      const searchTerms = (query as string).trim().toLowerCase();
      
      switch (filter) {
        case 'name':
          searchCondition = {
            ...searchCondition,
            OR: [
              {
                first_name: {
                  contains: searchTerms,
                  mode: 'insensitive' as Prisma.QueryMode
                }
              },
              {
                last_name: {
                  contains: searchTerms,
                  mode: 'insensitive' as Prisma.QueryMode
                }
              }
            ]
          };
          break;

        case 'email':
          searchCondition = {
            ...searchCondition,
            email: {
              contains: searchTerms,
              mode: 'insensitive' as Prisma.QueryMode
            }
          };
          break;

        case 'phone':
          searchCondition = {
            ...searchCondition,
            phone: {
              contains: searchTerms,
              mode: 'insensitive' as Prisma.QueryMode
            }
          };
          break;
      }

      // Exécuter la requête avec pagination
      const [users, total] = await Promise.all([
        prisma.users.findMany({
          where: searchCondition,
          select: {
            id: true,
            first_name: true,
            last_name: true,
            email: true,
            phone: true,
            role: true,
            addresses: {
              where: { is_default: true },
              select: {
                id: true,
                street: true,
                city: true,
                postal_code: true
              }
            }
          },
          skip: (Number(page) - 1) * Number(limit),
          take: Number(limit),
          orderBy: { created_at: 'desc' }
        }),
        prisma.users.count({ where: searchCondition })
      ]);

      return res.json({
        success: true,
        data: users,
        pagination: {
          total,
          currentPage: Number(page),
          limit: Number(limit),
          totalPages: Math.ceil(total / Number(limit))
        }
      });

    } catch (error) {
      console.error('[UserController] Search error:', error);
      return res.status(500).json({
        success: false,
        error: 'Erreur lors de la recherche des utilisateurs'
      });
    }
  }
}

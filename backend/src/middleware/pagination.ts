import { Request, Response, NextFunction } from 'express';
import { Pagination, PaginationParams } from '../utils/pagination';

export const paginationMiddleware = (
  defaultLimit: number = 10,
  maxLimit: number = 100,
  allowedSortFields: string[] = ['createdAt']
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      // Extraire et valider la page
      const page = Math.max(1, parseInt(req.query.page as string) || 1);

      // Extraire et valider la limite
      let limit = parseInt(req.query.limit as string) || defaultLimit;
      limit = Math.min(maxLimit, Math.max(1, limit));

      // Extraire et valider le tri
      const sortBy = req.query.sortBy as string;
      if (sortBy && !allowedSortFields.includes(sortBy)) {
        return res.status(400).json({
          error: `Le champ de tri doit être l'un des suivants : ${allowedSortFields.join(', ')}`
        });
      }

      // Extraire et valider l'ordre de tri
      const sortOrder = (req.query.sortOrder as string)?.toLowerCase() === 'asc' ? 'asc' : 'desc';

      // Ajouter les paramètres de pagination à la requête
      req.pagination = {
        page,
        limit,
        sortBy: sortBy || allowedSortFields[0],
        sortOrder
      };

      next();
    } catch (error) {
      next(error);
    }
  };
};

// Types pour étendre l'interface Request
declare global {
  namespace Express {
    interface Request {
      pagination: PaginationParams;
    }
  }
}

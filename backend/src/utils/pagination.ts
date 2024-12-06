import { Request } from 'express';

// Interface pour les paramètres de pagination
export interface PaginationParams {
  page: number;
  limit: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

// Interface pour la réponse paginée
export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    currentPage: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
    hasMore: boolean;
  };
}

// Classe utilitaire pour la pagination
export class Pagination {
  // Extraire les paramètres de pagination de la requête
  static getParams(req: Request): PaginationParams {
    const page = Math.max(1, parseInt(req.query.page as string) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit as string) || 10));
    const sortBy = (req.query.sortBy as string) || 'createdAt';
    const sortOrder = (req.query.sortOrder as string === 'asc' ? 'asc' : 'desc');

    return { page, limit, sortBy, sortOrder };
  }

  // Calculer l'offset pour la requête à la base de données
  static getOffset(page: number, limit: number): number {
    return (page - 1) * limit;
  }

  // Créer la réponse paginée
  static createResponse<T>(
    data: T[],
    totalItems: number,
    page: number,
    limit: number
  ): PaginatedResponse<T> {
    const totalPages = Math.ceil(totalItems / limit);

    return {
      data,
      pagination: {
        currentPage: page,
        pageSize: limit,
        totalItems,
        totalPages,
        hasMore: page < totalPages
      }
    };
  }

  // Créer les options de tri pour Firestore
  static createFirestoreOptions(params: PaginationParams) {
    return {
      orderBy: [{ field: params.sortBy || 'createdAt', direction: params.sortOrder || 'desc' }],
      limit: params.limit,
      offset: this.getOffset(params.page, params.limit)
    };
  }

  // Créer les options de tri pour MongoDB
  static createMongoDBOptions(params: PaginationParams) {
    return {
      sort: { [params.sortBy || 'createdAt']: params.sortOrder === 'asc' ? 1 : -1 },
      skip: this.getOffset(params.page, params.limit),
      limit: params.limit
    };
  }
}

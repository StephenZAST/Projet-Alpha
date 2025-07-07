import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';

export class UserController {
  /**
   * Endpoint de recherche paginée et filtrée d'utilisateurs (tous rôles, recherche, etc.)
   * GET /api/users/search?role=CLIENT&page=1&limit=10&query=...&filter=name
   */
  static async searchUsers(req: Request, res: Response) {
    try {
      const {
        query = '',
        filter = 'all',
        role = 'all',
        page = 1,
        limit = 10,
      } = req.query;

      // Appel du service centralisé
      const result = await AuthService.searchUsers({
        role: String(role),
        query: String(query),
        filter: String(filter),
        page: Number(page),
        limit: Number(limit)
      });

      return res.json({
        success: true,
        data: result.data,
        pagination: result.pagination
      });
    } catch (error: any) {
      console.error('[UserController] Search error:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erreur lors de la recherche des utilisateurs',
        details: error.stack || error
      });
    }
  }
}

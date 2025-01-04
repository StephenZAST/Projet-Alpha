import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import bcrypt from 'bcryptjs';

export class AuthController {
  static async register(req: Request, res: Response) {
    try {
      const { email, password, firstName, lastName, phone, affiliateCode, role } = req.body;
      const result = await AuthService.register(email, password, firstName, lastName, phone, affiliateCode, role);
      res.json({ data: result });
    } catch (error: any) {
      console.error('Registration error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;
      const { user, token } = await AuthService.login(email, password);
      res.cookie('token', token, { httpOnly: true, secure: process.env.NODE_ENV === 'production' });
      res.json({ data: { user, token } });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

static async getCurrentUser(req: Request, res: Response) {
  try {
    console.log('req.user in AuthController:', req.user);
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    const result = await AuthService.getCurrentUser(userId);
    res.json({ data: result });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

  static async createAffiliate(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.createAffiliate(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllUsers(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.getAllUsers();
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async createAdmin(req: Request, res: Response) {
    try {
      const { email, password, firstName, lastName, phone } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.createAdmin(email, password, firstName, lastName, phone);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateProfile(req: Request, res: Response) {
    try {
      const { email, firstName, lastName, phone } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.updateProfile(userId, email, firstName, lastName, phone);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async changePassword(req: Request, res: Response) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.changePassword(userId, currentPassword, newPassword);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteAccount(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.deleteAccount(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteUser(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const targetUserId = req.params.userId;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.deleteUser(targetUserId, userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateUser(req: Request, res: Response) {
    try {
      const { email, firstName, lastName, phone, role } = req.body;
      const userId = req.user?.id;
      const targetUserId = req.params.userId;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AuthService.updateUser(targetUserId, email, firstName, lastName, phone, role);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async logout(req: Request, res: Response) {
    try {
      // Simplifier la logique de déconnexion
      res.clearCookie('token');
      res.json({ success: true, message: 'Logged out successfully' });
    } catch (error: any) {
      console.error('Logout error:', error);
      res.status(400).json({ error: error.message });
    }
  }
}

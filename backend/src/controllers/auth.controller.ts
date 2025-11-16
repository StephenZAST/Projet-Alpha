import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken'; 

const generateToken = (user: any) => {
  return jwt.sign(
    { 
      id: user.id, 
      role: user.role,  // S'assurer que le rôle est inclus
      email: user.email 
    },
    process.env.JWT_SECRET!,
    { expiresIn: '7d' }
  );
}; 

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
        // 🔐 Support pour Email OU Téléphone
        const { identifier, password } = req.body;
        console.log('Login request received:', { identifier, password });

        if (!identifier || !password) {
          return res.status(400).json({ 
            error: 'Email/Phone and password are required' 
          });
        } 

        // Utiliser la nouvelle méthode qui supporte email ET téléphone
        const { user, token } = await AuthService.loginWithPhoneOrEmail(identifier, password);
        
        // Définir le cookie avec le token
        res.cookie('token', token, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 24 * 60 * 60 * 1000 // 24 heures
        });

        // Récupérer l'utilisateur avec ses adresses
        const userData = await AuthService.getCurrentUser(user.id);
        const userAddresses = userData.addresses?.filter(addr => addr.userId === userData.id) || [];

        // Envoyer la réponse
        res.json({
            success: true,
            data: {
                user: userData,
                token: token,
                addresses: userAddresses // Envoyer uniquement les adresses de l'utilisateur
            }
        });
    } catch (error: any) {
        console.error('Login error:', error);
        res.status(401).json({
            success: false,
            error: error.message || 'Authentication failed'
        });
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

      const result = await AuthService.getAllUsers({});
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

  static async resetPassword(req: Request, res: Response) {
    try {
      const { email } = req.body;
      console.log('Attempting password reset for email:', email);
      
      await AuthService.resetPassword(email);
      
      console.log('Password reset email sent successfully');
      res.json({ message: 'Password reset email sent' });
    } catch (error: any) {
      console.error('Reset password error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async verifyCodeAndResetPassword(req: Request, res: Response) {
    try {
        const { email, code, newPassword } = req.body;
        console.log('Reset password request received for:', email);

        await AuthService.verifyCodeAndResetPassword(email, code, newPassword);

        // Test immédiat de connexion
        try {
            const { user, token } = await AuthService.login(email, newPassword);
            console.log('Test login successful with new password');
            
            res.json({
                success: true,
                message: 'Password reset and verified successfully',
                data: { user, token }
            });
        } catch (loginError) {
            console.error('Test login failed:', loginError);
            res.status(400).json({
                success: false,
                error: 'Password reset succeeded but verification failed'
            });
        }
    } catch (error: any) {
        console.error('Password reset failed:', error);
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
}

static async adminResetUserPassword(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      // Générer un mot de passe temporaire sécurisé
      const tempPassword = Math.random().toString(36).slice(-10) + Math.floor(1000 + Math.random() * 9000);
      // Mettre à jour le mot de passe de l'utilisateur
      const user = await AuthService.adminResetUserPassword(userId, tempPassword);
      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            phone: user.phone,
            role: user.role
          },
          tempPassword
        }
      });
    } catch (error: any) {
      res.status(500).json({ success: false, error: error.message });
    }
  }
}

import { Request, Response, NextFunction } from 'express';
import { auth } from '../services/firebase';
import { DecodedIdToken } from 'firebase-admin/auth';
import { UserRole } from '../models/user';
import { AdminRole } from '../models/admin'; // Import AdminRole

// Extend Express Request type to include user information
declare global {
  namespace Express {
    interface Request {
      user?: DecodedIdToken & {
        role?: UserRole | AdminRole; // Allow both UserRole and AdminRole
        uid?: string;
      };
    }
  }
}

export async function authenticateUser(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authorization header must start with Bearer' });
    }

    const token = authHeader.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    // Verify the Firebase token
    const decodedToken = await auth.verifyIdToken(token);
    
    // Attach the decoded token to the request object
    req.user = decodedToken;
    
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
}

// Middleware pour vérifier les rôles spécifiques
export function requireRole(roles: UserRole[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !req.user.role) {
      return res.status(403).json({ error: 'Access denied. Authentication required.' });
    }

    if (!roles.includes(req.user.role as UserRole)) {
      return res.status(403).json({ 
        error: 'Access denied. Insufficient privileges.',
        requiredRoles: roles,
        currentRole: req.user.role
      });
    }

    next();
  };
}

// Middleware pour vérifier les rôles d'administrateur
export function requireAdminRole(roles: AdminRole[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !req.user.role) {
      return res.status(403).json({ error: 'Access denied. Authentication required.' });
    }

    if (!roles.includes(req.user.role as AdminRole)) {
      return res.status(403).json({
        error: 'Access denied. Insufficient privileges.',
        requiredRoles: roles,
        currentRole: req.user.role
      });
    }

    next();
  };
}


// Middlewares spécifiques pour chaque rôle
export const requireSuperAdmin = requireRole([UserRole.SUPER_ADMIN]);
export const requireServiceClient = requireRole([UserRole.SERVICE_CLIENT, UserRole.SUPER_ADMIN]);
export const requireSecretaire = requireRole([UserRole.SECRETAIRE, UserRole.SUPER_ADMIN]);
export const requireLivreur = requireRole([UserRole.LIVREUR, UserRole.SUPER_ADMIN]);
export const requireDriver = requireRole([UserRole.LIVREUR, UserRole.SUPER_ADMIN]); // Alias pour requireLivreur
export const requireSuperviseur = requireRole([UserRole.SUPERVISEUR, UserRole.SUPER_ADMIN]);

// Middleware pour vérifier si l'utilisateur est le propriétaire de la ressource
export function requireOwnership(getUserId: (req: Request) => string) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !req.user.uid) {
      return res.status(403).json({ error: 'Access denied. Authentication required.' });
    }

    const resourceUserId = getUserId(req);
    
    if (req.user.uid !== resourceUserId && req.user.role !== UserRole.SUPER_ADMIN) {
      return res.status(403).json({ error: 'Access denied. You can only access your own resources.' });
    }

    next();
  };
}

// Middleware pour les commandes one-click
export function validateOneClickOrder(req: Request, res: Response, next: NextFunction) {
  if (!req.user || !req.user.uid) {
    return res.status(403).json({ error: 'Authentication required for one-click orders.' });
  }

  // Vérifier si l'utilisateur a les informations nécessaires pour une commande one-click
  // Cette vérification sera implémentée dans le service utilisateur
  next();
}

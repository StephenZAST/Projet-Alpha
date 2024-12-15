export enum AdminRole {
  SUPER_ADMIN_MASTER = 'super_admin_master', // Votre compte unique
  SUPER_ADMIN = 'super_admin',               // Super admins secondaires
  SECRETARY = 'secretary',
  DELIVERY = 'delivery',
  CUSTOMER_SERVICE = 'customer_service',
  SUPERVISOR = 'supervisor'
}

export interface IAdmin {
  id: string; // Changed from _id to id for consistency
  userId: string;
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: AdminRole;
  phoneNumber: string;
  isActive: boolean;
  createdBy: string;      // Change createdBy type to string
  lastLogin?: Date;
  createdAt: Date;
  updatedAt: Date;
  permissions: string[];  // Liste des permissions spécifiques
  isMasterAdmin: boolean; // Pour identifier le super admin principal
  googleAIKey?: string;  // Ajout de la clé API Google AI
}

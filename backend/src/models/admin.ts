import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

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

// Use Supabase to store admin data
const adminsTable = 'admins';

// Function to get admin data
export async function getAdmin(id: string): Promise<IAdmin | null> {
  const { data, error } = await supabase.from(adminsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch admin', 'INTERNAL_SERVER_ERROR');
  }

  return data as IAdmin;
}

// Function to create admin
export async function createAdmin(adminData: IAdmin): Promise<IAdmin> {
  // Check if master admin already exists
  if (adminData.isMasterAdmin) {
    const { data: masterAdmins, error: masterError } = await supabase.from(adminsTable).select('*').eq('isMasterAdmin', true);

    if (masterError) {
      throw new AppError(500, 'Failed to check for existing master admin', 'INTERNAL_SERVER_ERROR');
    }

    if (masterAdmins && masterAdmins.length > 0) {
      throw new AppError(400, 'A master admin already exists', errorCodes.MASTER_ADMIN_EXISTS);
    }
  }

  const { data, error } = await supabase.from(adminsTable).insert([adminData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create admin', 'INTERNAL_SERVER_ERROR');
  }

  return data as IAdmin;
}

// Function to update admin
export async function updateAdmin(id: string, adminData: Partial<IAdmin>): Promise<IAdmin> {
  const currentAdmin = await getAdmin(id);

  if (!currentAdmin) {
    throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
  }

  // Prevent modification of master admin status
  if (adminData.isMasterAdmin !== undefined && currentAdmin.isMasterAdmin) {
    throw new AppError(400, 'Cannot modify master admin status', errorCodes.MASTER_ADMIN_MODIFICATION);
  }

  const { data, error } = await supabase.from(adminsTable).update(adminData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update admin', 'INTERNAL_SERVER_ERROR');
  }

  return data as IAdmin;
}

// Function to delete admin
export async function deleteAdmin(id: string): Promise<void> {
  const admin = await getAdmin(id);

  if (!admin) {
    throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
  }

  // Prevent deletion of master admin
  if (admin.isMasterAdmin) {
    throw new AppError(400, 'Cannot delete master admin', errorCodes.MASTER_ADMIN_DELETION);
  }

  const { error } = await supabase.from(adminsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete admin', 'INTERNAL_SERVER_ERROR');
  }
}

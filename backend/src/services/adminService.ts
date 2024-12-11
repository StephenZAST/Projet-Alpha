import supabase from '../config/supabase';
import { IAdmin, AdminRole } from '../models/admin';
import { AppError, errorCodes } from '../utils/errors';
import { hashPassword, comparePassword } from '../utils/auth';

export class AdminService {
  static async createAdmin(adminData: IAdmin): Promise<IAdmin> {
    if (adminData.isMasterAdmin) {
      const { data: masterAdmins, error: masterError } = await supabase.from('admins').select('*').eq('isMasterAdmin', true);

      if (masterError) {
        throw new AppError(500, 'Failed to check for existing master admin', 'INTERNAL_SERVER_ERROR');
      }

      if (masterAdmins && masterAdmins.length > 0) {
        throw new AppError(400, 'A master admin already exists', errorCodes.MASTER_ADMIN_EXISTS);
      }
    }

    const hashedPassword = await hashPassword(adminData.password);
    const { data, error } = await supabase.from('admins').insert([
      {
        ...adminData,
        password: hashedPassword,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create admin', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to create admin', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdmin;
  }

  static async getAdmin(email: string): Promise<IAdmin | null> {
    const { data, error } = await supabase.from('admins').select('*').eq('email', email).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch admin', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdmin;
  }

  static async updateAdmin(id: string, adminData: Partial<IAdmin>): Promise<IAdmin | null> {
    const currentAdmin = await this.getAdminById(id);

    if (!currentAdmin) {
      throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }

    if (adminData.isMasterAdmin !== undefined && currentAdmin.isMasterAdmin) {
      throw new AppError(400, 'Cannot modify master admin status', errorCodes.MASTER_ADMIN_MODIFICATION);
    }

    if (adminData.password) {
      adminData.password = await hashPassword(adminData.password);
    }

    const { data, error } = await supabase.from('admins').update(adminData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update admin', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdmin;
  }

  static async deleteAdmin(id: string): Promise<void> {
    const admin = await this.getAdminById(id);

    if (!admin) {
      throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }

    if (admin.isMasterAdmin) {
      throw new AppError(400, 'Cannot delete master admin', errorCodes.MASTER_ADMIN_DELETION);
    }

    const { error } = await supabase.from('admins').delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete admin', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async getAdminById(id: string): Promise<IAdmin | null> {
    const { data, error } = await supabase.from('admins').select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch admin', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdmin;
  }

  static async loginAdmin(email: string, password: string): Promise<IAdmin | null> {
    const admin = await this.getAdmin(email);

    if (!admin) {
      return null;
    }

    const isPasswordValid = await comparePassword(password, admin.password);

    if (!isPasswordValid) {
      return null;
    }

    return admin;
  }

  static async getAllAdmins(): Promise<IAdmin[]> {
    const { data, error } = await supabase.from('admins').select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch all admins', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to fetch all admins', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdmin[];
  }

  static async toggleAdminStatus(id: string, isActive: boolean): Promise<IAdmin | null> {
    const admin = await this.getAdminById(id);

    if (!admin) {
      throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }

    const { data, error } = await supabase.from('admins').update({ isActive }).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to toggle admin status', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdmin;
  }

  static async createMasterAdmin(adminData: IAdmin): Promise<IAdmin> {
    if (!adminData.isMasterAdmin) {
      throw new AppError(400, 'Admin must be a master admin', 'INVALID_MASTER_ADMIN_DATA');
    }

    const { data: masterAdmins, error: masterError } = await supabase.from('admins').select('*').eq('isMasterAdmin', true);

    if (masterError) {
      throw new AppError(500, 'Failed to check for existing master admin', 'INTERNAL_SERVER_ERROR');
    }

    if (masterAdmins && masterAdmins.length > 0) {
      throw new AppError(400, 'A master admin already exists', errorCodes.MASTER_ADMIN_EXISTS);
    }

    const hashedPassword = await hashPassword(adminData.password);
    const { data, error } = await supabase.from('admins').insert([
      {
        ...adminData,
        password: hashedPassword,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create master admin', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to create master admin', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdmin;
  }
}

import { Request, Response, NextFunction } from 'express';
import { AdminService } from '../services/adminService';
import { AppError, errorCodes } from '../utils/errors';
import { createToken } from '../utils/auth';
import { IAdmin } from '../models/admin';

export const loginAdmin = async (req: Request, res: Response, next: NextFunction): Promise<IAdmin | null> => {
  const { email, password } = req.body;

  try {
    const admin = await AdminService.loginAdmin(email, password);

    if (!admin) {
      throw new AppError(401, 'Invalid credentials', 'UNAUTHORIZED');
    }

    const token = createToken({ id: admin.id, role: admin.role });
    res.status(200).json({ message: 'Login successful', admin, token });
    return admin;
  } catch (error) {
    next(error);
    return null;
  }
};

export const registerAdmin = async (req: Request, res: Response, next: NextFunction): Promise<IAdmin | null> => {
  const adminData = req.body;

  try {
    const admin = await AdminService.createAdmin(adminData);

    if (admin) {
      const token = createToken({ id: admin.id, role: admin.role });
      res.status(201).json({ message: 'Admin registered successfully', admin, token });
      return admin;
    } else {
      throw new AppError(500, 'Failed to register admin', 'INTERNAL_SERVER_ERROR');
    }
  } catch (error) {
    next(error);
    return null;
  }
};

export const updateAdmin = async (req: Request, res: Response, next: NextFunction): Promise<IAdmin | null> => {
  const { id } = req.params;
  const adminData = req.body;

  try {
    const admin = await AdminService.updateAdmin(id, adminData);

    if (admin) {
      res.status(200).json({ message: 'Admin updated successfully', admin });
      return admin;
    } else {
      throw new AppError(404, 'Admin not found', 'ADMIN_NOT_FOUND');
    }
  } catch (error) {
    next(error);
    return null;
  }
};

export const deleteAdmin = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;

  try {
    await AdminService.deleteAdmin(id);
    res.status(200).json({ message: 'Admin deleted successfully' });
  } catch (error) {
    next(error);
  }
};

export const getAllAdmins = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const admins = await AdminService.getAllAdmins();
    res.status(200).json({ admins });
  } catch (error) {
    next(error);
  }
};

export const getAdminById = async (req: Request, res: Response, next: NextFunction): Promise<IAdmin | null> => {
  const { id } = req.params;

  try {
    const admin = await AdminService.getAdminById(id);

    if (!admin) {
      throw new AppError(404, 'Admin not found', 'ADMIN_NOT_FOUND');
    }

    res.status(200).json({ admin });
    return admin;
  } catch (error) {
    next(error);
    return null;
  }
};

export const toggleAdminStatus = async (req: Request, res: Response, next: NextFunction): Promise<IAdmin | null> => {
  const { id } = req.params;
  const { isActive } = req.body;

  try {
    const admin = await AdminService.toggleAdminStatus(id, isActive);

    if (admin) {
      res.status(200).json({ message: 'Admin status toggled successfully', admin });
      return admin;
    } else {
      throw new AppError(404, 'Admin not found', 'ADMIN_NOT_FOUND');
    }
  } catch (error) {
    next(error);
    return null;
  }
};

export const createMasterAdmin = async (req: Request, res: Response, next: NextFunction): Promise<IAdmin | null> => {
  const adminData = req.body;

  try {
    const admin = await AdminService.createMasterAdmin(adminData);

    if (admin) {
      const token = createToken({ id: admin.id, role: admin.role });
      res.status(201).json({ message: 'Master admin created successfully', admin, token });
      return admin;
    } else {
      throw new AppError(500, 'Failed to create master admin', 'INTERNAL_SERVER_ERROR');
    }
  } catch (error) {
    next(error);
    return null;
  }
};

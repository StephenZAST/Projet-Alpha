import { Request, Response, NextFunction } from 'express';
import { AdminService } from '../services/adminService';
import { AppError, errorCodes } from '../utils/errors';
import { generateToken } from '../utils/jwt';
import { IAdmin } from '../models/admin';

export const loginAdmin = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { email, password } = req.body;

  try {
    const admin = await AdminService.loginAdmin(email, password);

    if (!admin) {
      throw new AppError(401, 'Invalid credentials', errorCodes.INVALID_CREDENTIALS);
    }

    const token = generateToken({
      uid: admin.id, role: admin.role,
      email: ''
    });
    res.status(200).json({ message: 'Login successful', admin, token });
  } catch (error) {
    next(error);
  }
};

export const registerAdmin = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const adminData = req.body;

  try {
    const admin = await AdminService.createAdmin(adminData);

    if (admin) {
      const token = generateToken({
        uid: admin.id, role: admin.role,
        email: ''
      });
      res.status(201).json({ message: 'Admin registered successfully', admin, token });
    } else {
      throw new AppError(500, 'Failed to register admin', errorCodes.ADMIN_CREATION_FAILED);
    }
  } catch (error) {
    next(error);
  }
};

export const updateAdmin = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;
  const adminData = req.body;

  try {
    const admin = await AdminService.updateAdmin(id, adminData);

    if (admin) {
      res.status(200).json({ message: 'Admin updated successfully', admin });
    } else {
      throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }
  } catch (error) {
    next(error);
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

export const getAllAdmins = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const admins = await AdminService.getAllAdmins();
    res.status(200).json({ admins });
  } catch (error) {
    next(error);
  }
};

export const getAdminById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;

  try {
    const admin = await AdminService.getAdminById(id);

    if (!admin) {
      throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }

    res.status(200).json({ admin });
  } catch (error) {
    next(error);
  }
};

export const toggleAdminStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;
  const { isActive } = req.body;

  try {
    const admin = await AdminService.toggleAdminStatus(id, isActive);

    if (admin) {
      res.status(200).json({ message: 'Admin status toggled successfully', admin });
    } else {
      throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }
  } catch (error) {
    next(error);
  }
};

export const createMasterAdmin = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const adminData = req.body;

  try {
    const admin = await AdminService.createMasterAdmin(adminData);

    if (admin) {
      const token = generateToken({
        uid: admin.id, role: admin.role,
        email: ''
      });
      res.status(201).json({ message: 'Master admin created successfully', admin, token });
    } else {
      throw new AppError(500, 'Failed to create master admin', errorCodes.ADMIN_CREATION_FAILED);
    }
  } catch (error) {
    next(error);
  }
};

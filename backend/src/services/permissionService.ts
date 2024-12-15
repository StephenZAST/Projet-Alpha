import { Permission } from '../models/permission';
import { AppError, errorCodes } from '../utils/errors';
import { getPermission, createPermission, updatePermission, deletePermission } from './permissionService/permissionManagement';

export class PermissionService {
  async getPermission(id: string): Promise<Permission | null> {
    return getPermission(id);
  }

  async createPermission(permissionData: Permission): Promise<Permission> {
    return createPermission(permissionData);
  }

  async updatePermission(id: string, permissionData: Partial<Permission>): Promise<Permission> {
    return updatePermission(id, permissionData);
  }

  async deletePermission(id: string): Promise<void> {
    return deletePermission(id);
  }
}

export const permissionService = new PermissionService();

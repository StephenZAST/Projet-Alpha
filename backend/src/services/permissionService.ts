import { Permission } from '../models/permission';
import { AppError, errorCodes } from '../utils/errors';
import {
  getPermissionById,
  createPermissionUtil,
  updatePermission,
  deletePermissionById,
  initializeDefaultPermissions,
  getPermissionsByRole,
  removePermissionById,
  getRoleMatrix,
  getResourcePermissions,
  getPermissions
} from './permissionService/utils';

export class PermissionService {
  async getPermissions(): Promise<Permission[]> {
    return getPermissions();
  }

  async getPermissionById(id: string): Promise<Permission | null> {
    return getPermissionById(id);
  }

  async createPermission(permissionData: Permission): Promise<Permission> {
    return createPermissionUtil(permissionData);
  }

  async updatePermission(id: string, name: string, description: string, roles: string[]): Promise<Permission> {
    return updatePermission(id, { name, description, roles });
  }

  async deletePermission(id: string): Promise<void> {
    return deletePermissionById(id);
  }

  async initializeDefaultPermissions(): Promise<void> {
    const defaultPermissions: Permission[] = [
      { name: 'create-article', description: 'Permission to create articles', roles: ['SUPER_ADMIN', 'EDITOR'] },
      { name: 'update-article', description: 'Permission to update articles', roles: ['SUPER_ADMIN', 'EDITOR'] },
      { name: 'delete-article', description: 'Permission to delete articles', roles: ['SUPER_ADMIN', 'EDITOR'] },
      { name: 'publish-article', description: 'Permission to publish articles', roles: ['SUPER_ADMIN', 'EDITOR'] },
      { name: 'manage-users', description: 'Permission to manage users', roles: ['SUPER_ADMIN'] },
      { name: 'manage-permissions', description: 'Permission to manage permissions', roles: ['SUPER_ADMIN'] },
    ];
    return initializeDefaultPermissions(defaultPermissions);
  }

  async getPermissionsByRole(role: string): Promise<Permission[]> {
    return getPermissionsByRole(role);
  }

  async removePermission(id: string): Promise<void> {
    return removePermissionById(id);
  }

  async getRoleMatrix(): Promise<any> {
    return getRoleMatrix();
  }

  async getResourcePermissions(resource: string): Promise<Permission[]> {
    return getResourcePermissions(resource);
  }
}

export const permissionService = new PermissionService();

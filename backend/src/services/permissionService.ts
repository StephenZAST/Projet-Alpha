import supabase from '../config/supabase';
import { Permission } from '../models/permission';
import AppError from '../utils/AppError';

export class PermissionService {
  static async createPermission(name: string, description: string, roles: string[]): Promise<Permission> {
    if (!name || !description || !roles) {
      throw new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA');
    }

    try {
      const { data, error } = await supabase.from('permissions').insert([
        {
          name,
          description,
          roles: roles.join(','),
          created_at: new Date().toISOString()
        }
      ]).select().single();

      if (error) {
        throw new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR');
      }

      if (!data) {
        throw new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR');
      }

      return data as Permission;
    } catch (error) {
      throw new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async getPermissions(): Promise<Permission[]> {
    try {
      const { data, error } = await supabase.from('permissions').select('*');

      if (error) {
        throw new AppError(500, 'Failed to fetch permissions', 'INTERNAL_SERVER_ERROR');
      }

      if (!data) {
        throw new AppError(500, 'Failed to fetch permissions', 'INTERNAL_SERVER_ERROR');
      }

      return data.map((permission: Permission) => {
        if (typeof permission.roles === 'string') {
          return {
            ...permission,
            roles: permission.roles.split(',').map((role: string) => role.trim())
          };
        } else {
          return permission;
        }
      }) as Permission[];
    } catch (error) {
      throw new AppError(500, 'Failed to fetch permissions', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async getPermissionById(id: string): Promise<Permission | null> {
    if (!id) {
      throw new AppError(400, 'ID is required', 'INVALID_ID');
    }

    try {
      const { data, error } = await supabase.from('permissions').select('*').eq('id', id).single();

      if (error) {
        throw new AppError(500, 'Failed to fetch permission', 'INTERNAL_SERVER_ERROR');
      }

      if (data && typeof data.roles === 'string') {
        data.roles = data.roles.split(',').map((role: string) => role.trim());
      }

      return data as Permission;
    } catch (error) {
      throw new AppError(500, 'Failed to fetch permission', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async updatePermission(id: string, name: string, description: string, roles: string[]): Promise<Permission | null> {
    if (!id || !name || !description || !roles) {
      throw new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA');
    }

    try {
      const { data, error } = await supabase.from('permissions').update({
        name,
        description,
        roles: roles.join(','),
        updated_at: new Date().toISOString()
      }).eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Failed to update permission', 'INTERNAL_SERVER_ERROR');
      }

      if (data && typeof data.roles === 'string') {
        data.roles = data.roles.split(',').map((role: string) => role.trim());
      }

      return data as Permission;
    } catch (error) {
      throw new AppError(500, 'Failed to update permission', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async deletePermission(id: string): Promise<Permission | null> {
    if (!id) {
      throw new AppError(400, 'ID is required', 'INVALID_ID');
    }

    try {
      const { data, error } = await supabase.from('permissions').delete().eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Failed to delete permission', 'INTERNAL_SERVER_ERROR');
      }

      if (data && typeof data.roles === 'string') {
        data.roles = data.roles.split(',').map((role: string) => role.trim());
      }

      return data as Permission;
    } catch (error) {
      throw new AppError(500, 'Failed to delete permission', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async initializeDefaultPermissions(): Promise<void> {
    const defaultPermissions = [
      { name: 'create_user', description: 'Create a new user', roles: ['admin'] },
      { name: 'update_user', description: 'Update user information', roles: ['admin', 'manager'] },
      { name: 'delete_user', description: 'Delete a user', roles: ['admin'] },
      // Add more default permissions as needed
    ];

    for (const permission of defaultPermissions) {
      try {
        await this.createPermission(permission.name, permission.description, permission.roles);
      } catch (error) {
        console.error('Failed to initialize default permission:', error);
      }
    }
  }

  static async getPermissionsByRole(role: string): Promise<Permission[]> {
    try {
      const { data, error } = await supabase.from('permissions').select('*').eq('roles', role);

      if (error) {
        throw new AppError(500, 'Failed to fetch permissions by role', 'INTERNAL_SERVER_ERROR');
      }

      if (!data) {
        throw new AppError(500, 'Failed to fetch permissions by role', 'INTERNAL_SERVER_ERROR');
      }

      return data.map((permission: Permission) => {
        if (typeof permission.roles === 'string') {
          return {
            ...permission,
            roles: permission.roles.split(',').map((role: string) => role.trim())
          };
        } else {
          return permission;
        }
      }) as Permission[];
    } catch (error) {
      throw new AppError(500, 'Failed to fetch permissions by role', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async addPermission(permission: Permission): Promise<Permission> {
    try {
      const { data, error } = await supabase.from('permissions').insert([
        {
          name: permission.name,
          description: permission.description,
          roles: permission.roles.join(','),
          created_at: new Date().toISOString()
        }
      ]).select().single();

      if (error) {
        throw new AppError(500, 'Failed to add permission', 'INTERNAL_SERVER_ERROR');
      }

      if (!data) {
        throw new AppError(500, 'Failed to add permission', 'INTERNAL_SERVER_ERROR');
      }

      return data as Permission;
    } catch (error) {
      throw new AppError(500, 'Failed to add permission', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async removePermission(id: string): Promise<Permission | null> {
    if (!id) {
      throw new AppError(400, 'ID is required', 'INVALID_ID');
    }

    try {
      const { data, error } = await supabase.from('permissions').delete().eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Failed to remove permission', 'INTERNAL_SERVER_ERROR');
      }

      if (data && typeof data.roles === 'string') {
        data.roles = data.roles.split(',').map((role: string) => role.trim());
      }

      return data as Permission;
    } catch (error) {
      throw new AppError(500, 'Failed to remove permission', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async getRoleMatrix(): Promise<Record<string, string[]>> {
    try {
      const { data, error } = await supabase.from('permissions').select('*');

      if (error) {
        throw new AppError(500, 'Failed to fetch role matrix', 'INTERNAL_SERVER_ERROR');
      }

      if (!data) {
        throw new AppError(500, 'Failed to fetch role matrix', 'INTERNAL_SERVER_ERROR');
      }

      const roleMatrix: Record<string, string[]> = {};

      data.forEach((permission: Permission) => {
        if (typeof permission.roles === 'string') {
          permission.roles.split(',').forEach((role: string) => {
            role = role.trim();
            if (!roleMatrix[role]) {
              roleMatrix[role] = [];
            }
            roleMatrix[role].push(permission.name);
          });
        }
      });

      return roleMatrix;
    } catch (error) {
      throw new AppError(500, 'Failed to fetch role matrix', 'INTERNAL_SERVER_ERROR');
    }
  }

  static async getResourcePermissions(resource: string): Promise<Permission[]> {
    try {
      const { data, error } = await supabase.from('permissions').select('*').eq('resource', resource);

      if (error) {
        throw new AppError(500, 'Failed to fetch resource permissions', 'INTERNAL_SERVER_ERROR');
      }

      if (!data) {
        throw new AppError(500, 'Failed to fetch resource permissions', 'INTERNAL_SERVER_ERROR');
      }

      return data.map((permission: Permission) => {
        if (typeof permission.roles === 'string') {
          return {
            ...permission,
            roles: permission.roles.split(',').map((role: string) => role.trim())
          };
        } else {
          return permission;
        }
      }) as Permission[];
    } catch (error) {
      throw new AppError(500, 'Failed to fetch resource permissions', 'INTERNAL_SERVER_ERROR');
    }
  }
}

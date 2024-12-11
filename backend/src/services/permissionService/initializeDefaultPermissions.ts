import { createPermission } from './createPermission';
import { AppError, errorCodes } from '../../utils/errors';

export const initializeDefaultPermissions = async (): Promise<void> => {
  const defaultPermissions = [
    { name: 'create_user', description: 'Create a new user', roles: ['admin'] },
    { name: 'update_user', description: 'Update user information', roles: ['admin', 'manager'] },
    { name: 'delete_user', description: 'Delete a user', roles: ['admin'] },
    // Add more default permissions as needed
  ];

  for (const permission of defaultPermissions) {
    try {
      await createPermission(permission.name, permission.description, permission.roles);
    } catch (error) {
      console.error('Failed to initialize default permission:', error);
    }
  }
};

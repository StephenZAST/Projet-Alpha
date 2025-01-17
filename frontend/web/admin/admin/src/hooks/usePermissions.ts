import { useAuth } from './useAuth';
import { ROLE_PERMISSIONS } from '../config/permissions';
import type { Permission, Resource } from '../config/permissions';

export const usePermissions = () => {
  const { state } = useAuth();
  const userRole = state.user?.role;

  const hasPermission = (resource: Resource, action: Permission): boolean => {
    if (!userRole) return false;
    return ROLE_PERMISSIONS[userRole]?.[resource]?.includes(action) || false;
  };

  const getResourcePermissions = (resource: Resource): Permission[] => {
    if (!userRole) return [];
    return ROLE_PERMISSIONS[userRole]?.[resource] || [];
  };

  return {
    hasPermission,
    getResourcePermissions,
    isAdmin: userRole === 'ADMIN',
    isSuperAdmin: userRole === 'SUPER_ADMIN'
  };
};

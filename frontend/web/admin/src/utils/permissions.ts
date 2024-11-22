export enum Permission {
  // Admin permissions
  ADMIN_READ = 'admin:read',
  ADMIN_CREATE = 'admin:create',
  ADMIN_UPDATE = 'admin:update',
  ADMIN_DELETE = 'admin:delete',

  // User permissions
  USER_READ = 'user:read',
  USER_CREATE = 'user:create',
  USER_UPDATE = 'user:update',
  USER_DELETE = 'user:delete',

  // Order permissions
  ORDER_READ = 'order:read',
  ORDER_CREATE = 'order:create',
  ORDER_UPDATE = 'order:update',
  ORDER_DELETE = 'order:delete',

  // Delivery permissions
  DELIVERY_READ = 'delivery:read',
  DELIVERY_CREATE = 'delivery:create',
  DELIVERY_UPDATE = 'delivery:update',
  DELIVERY_DELETE = 'delivery:delete',

  // System permissions
  SYSTEM_LOGS = 'system:logs',
  SYSTEM_SETTINGS = 'system:settings',
}

export const Roles = {
  SUPER_ADMIN: 'SUPER_ADMIN',
  ADMIN: 'ADMIN',
  MANAGER: 'MANAGER',
  USER: 'USER',
} as const;

export type Role = typeof Roles[keyof typeof Roles];

export const RolePermissions: Record<Role, Permission[]> = {
  [Roles.SUPER_ADMIN]: Object.values(Permission),
  [Roles.ADMIN]: [
    Permission.ADMIN_READ,
    Permission.USER_READ,
    Permission.USER_CREATE,
    Permission.USER_UPDATE,
    Permission.USER_DELETE,
    Permission.ORDER_READ,
    Permission.ORDER_CREATE,
    Permission.ORDER_UPDATE,
    Permission.ORDER_DELETE,
    Permission.DELIVERY_READ,
    Permission.DELIVERY_CREATE,
    Permission.DELIVERY_UPDATE,
    Permission.DELIVERY_DELETE,
    Permission.SYSTEM_LOGS,
  ],
  [Roles.MANAGER]: [
    Permission.USER_READ,
    Permission.ORDER_READ,
    Permission.ORDER_CREATE,
    Permission.ORDER_UPDATE,
    Permission.DELIVERY_READ,
    Permission.DELIVERY_CREATE,
    Permission.DELIVERY_UPDATE,
  ],
  [Roles.USER]: [
    Permission.USER_READ,
    Permission.ORDER_READ,
    Permission.ORDER_CREATE,
    Permission.DELIVERY_READ,
  ],
};

export const checkPermission = (
  userPermissions: string[],
  requiredPermission: string
): boolean => {
  return userPermissions.includes(requiredPermission);
};

export const hasAnyPermission = (
  userPermissions: string[],
  requiredPermissions: string[]
): boolean => {
  return requiredPermissions.some((permission) =>
    userPermissions.includes(permission)
  );
};

export const hasAllPermissions = (
  userPermissions: string[],
  requiredPermissions: string[]
): boolean => {
  return requiredPermissions.every((permission) =>
    userPermissions.includes(permission)
  );
};

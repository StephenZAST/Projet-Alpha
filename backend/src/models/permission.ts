import { AdminRole } from './admin';
import { firestore } from 'firebase-admin';

export enum PermissionAction {
    CREATE = 'CREATE',
    READ = 'READ',
    UPDATE = 'UPDATE',
    DELETE = 'DELETE',
    MANAGE = 'MANAGE'
}

export enum PermissionResource {
    ADMIN = 'ADMIN',
    USER = 'USER',
    ORDER = 'ORDER',
    PAYMENT = 'PAYMENT',
    REPORT = 'REPORT',
    SETTING = 'SETTING',
    LOG = 'LOG',
    NOTIFICATION = 'NOTIFICATION'
}

export interface Permission {
    role: AdminRole;
    resource: PermissionResource;
    actions: PermissionAction[];
    conditions?: Record<string, any>;
    description: string;
    createdAt: firestore.Timestamp;
    updatedAt: firestore.Timestamp;
}

// Collection reference
export const permissionsCollection = firestore().collection('permissions');

// Default permissions for each role
export const defaultPermissions: Omit<Permission, 'createdAt' | 'updatedAt'>[] = [
    // SUPER_ADMIN_MASTER
    {
        role: AdminRole.SUPER_ADMIN_MASTER,
        resource: PermissionResource.ADMIN,
        actions: Object.values(PermissionAction),
        description: 'Full access to all admin operations'
    },
    {
        role: AdminRole.SUPER_ADMIN_MASTER,
        resource: PermissionResource.LOG,
        actions: [PermissionAction.READ, PermissionAction.MANAGE],
        description: 'Full access to all logs'
    },

    // SUPER_ADMIN
    {
        role: AdminRole.SUPER_ADMIN,
        resource: PermissionResource.ADMIN,
        actions: [PermissionAction.CREATE, PermissionAction.READ, PermissionAction.UPDATE],
        conditions: { excludedRoles: [AdminRole.SUPER_ADMIN_MASTER] },
        description: 'Can manage all admins except master admin'
    },

    // SECRETARY
    {
        role: AdminRole.SECRETARY,
        resource: PermissionResource.ORDER,
        actions: [PermissionAction.CREATE, PermissionAction.READ, PermissionAction.UPDATE],
        description: 'Can manage orders'
    },
    {
        role: AdminRole.SECRETARY,
        resource: PermissionResource.USER,
        actions: [PermissionAction.READ, PermissionAction.UPDATE],
        description: 'Can view and update user information'
    },

    // DELIVERY
    {
        role: AdminRole.DELIVERY,
        resource: PermissionResource.ORDER,
        actions: [PermissionAction.READ, PermissionAction.UPDATE],
        description: 'Can view and update order status'
    },

    // CUSTOMER_SERVICE
    {
        role: AdminRole.CUSTOMER_SERVICE,
        resource: PermissionResource.USER,
        actions: [PermissionAction.READ],
        description: 'Can view user information'
    },
    {
        role: AdminRole.CUSTOMER_SERVICE,
        resource: PermissionResource.ORDER,
        actions: [PermissionAction.READ],
        description: 'Can view order information'
    },

    // SUPERVISOR
    {
        role: AdminRole.SUPERVISOR,
        resource: PermissionResource.REPORT,
        actions: [PermissionAction.READ],
        description: 'Can view reports'
    },
    {
        role: AdminRole.SUPERVISOR,
        resource: PermissionResource.LOG,
        actions: [PermissionAction.READ],
        description: 'Can view logs'
    }
];

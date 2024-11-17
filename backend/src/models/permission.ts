import mongoose, { Schema, Document } from 'mongoose';
import { AdminRole } from './admin';

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

export interface IPermission extends Document {
    role: AdminRole;
    resource: PermissionResource;
    actions: PermissionAction[];
    conditions?: object;
    description: string;
    createdAt: Date;
    updatedAt: Date;
}

const permissionSchema = new Schema({
    role: {
        type: String,
        enum: Object.values(AdminRole),
        required: true
    },
    resource: {
        type: String,
        enum: Object.values(PermissionResource),
        required: true
    },
    actions: [{
        type: String,
        enum: Object.values(PermissionAction),
        required: true
    }],
    conditions: {
        type: Schema.Types.Mixed,
        default: {}
    },
    description: {
        type: String,
        required: true
    }
}, {
    timestamps: true
});

// Index composé pour une recherche rapide des permissions
permissionSchema.index({ role: 1, resource: 1 });

export const Permission = mongoose.model<IPermission>('Permission', permissionSchema);

// Permissions par défaut pour chaque rôle
export const defaultPermissions = [
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
        conditions: { role: { $ne: AdminRole.SUPER_ADMIN_MASTER } },
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
        actions: [PermissionAction.READ, PermissionAction.UPDATE],
        description: 'Can view and update orders'
    },

    // SUPERVISOR
    {
        role: AdminRole.SUPERVISOR,
        resource: PermissionResource.ORDER,
        actions: [PermissionAction.READ, PermissionAction.MANAGE],
        description: 'Can view and manage orders'
    },
    {
        role: AdminRole.SUPERVISOR,
        resource: PermissionResource.REPORT,
        actions: [PermissionAction.READ, PermissionAction.CREATE],
        description: 'Can view and create reports'
    }
];

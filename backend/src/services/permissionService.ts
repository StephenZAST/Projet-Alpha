import { Permission, IPermission, PermissionAction, PermissionResource, defaultPermissions } from '../models/permission';
import { AdminRole } from '../models/admin';
import { AppError } from '../utils/errors';

export class PermissionService {
    static async initializeDefaultPermissions(): Promise<void> {
        for (const permission of defaultPermissions) {
            await Permission.findOneAndUpdate(
                { role: permission.role, resource: permission.resource },
                permission,
                { upsert: true, new: true }
            );
        }
    }

    static async hasPermission(
        role: AdminRole,
        resource: PermissionResource,
        action: PermissionAction
    ): Promise<boolean> {
        const permission = await Permission.findOne({ role, resource });
        
        if (!permission) {
            return false;
        }

        return permission.actions.includes(action);
    }

    static async getPermissionsByRole(role: AdminRole): Promise<IPermission[]> {
        return await Permission.find({ role });
    }

    static async addPermission(
        role: AdminRole,
        resource: PermissionResource,
        actions: PermissionAction[],
        description: string,
        conditions?: object
    ): Promise<IPermission> {
        // Vérifier si la permission existe déjà
        const existingPermission = await Permission.findOne({ role, resource });
        if (existingPermission) {
            throw new AppError(400, 'Permission already exists for this role and resource');
        }

        // Créer une nouvelle permission
        const permission = new Permission({
            role,
            resource,
            actions,
            description,
            conditions
        });

        return await permission.save();
    }

    static async updatePermission(
        role: AdminRole,
        resource: PermissionResource,
        actions: PermissionAction[],
        description?: string,
        conditions?: object
    ): Promise<IPermission | null> {
        const updateData: any = { actions };
        if (description) updateData.description = description;
        if (conditions) updateData.conditions = conditions;

        return await Permission.findOneAndUpdate(
            { role, resource },
            updateData,
            { new: true }
        );
    }

    static async removePermission(
        role: AdminRole,
        resource: PermissionResource
    ): Promise<boolean> {
        const result = await Permission.deleteOne({ role, resource });
        return result.deletedCount > 0;
    }

    static async checkMultiplePermissions(
        role: AdminRole,
        permissions: Array<{
            resource: PermissionResource;
            action: PermissionAction;
        }>
    ): Promise<boolean> {
        for (const { resource, action } of permissions) {
            const hasPermission = await this.hasPermission(role, resource, action);
            if (!hasPermission) {
                return false;
            }
        }
        return true;
    }

    static async getResourcePermissions(
        resource: PermissionResource
    ): Promise<IPermission[]> {
        return await Permission.find({ resource });
    }

    static async getRoleMatrix(): Promise<Record<AdminRole, Record<PermissionResource, PermissionAction[]>>> {
        const permissions = await Permission.find();
        const matrix: Record<AdminRole, Record<PermissionResource, PermissionAction[]>> = {} as any;

        for (const role of Object.values(AdminRole)) {
            matrix[role] = {} as Record<PermissionResource, PermissionAction[]>;
            for (const resource of Object.values(PermissionResource)) {
                const permission = permissions.find(p => p.role === role && p.resource === resource);
                matrix[role][resource] = permission ? permission.actions : [];
            }
        }

        return matrix;
    }
}

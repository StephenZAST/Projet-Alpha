import { Permission, PermissionAction, PermissionResource, defaultPermissions, permissionsCollection } from '../models/permission';
import { AdminRole } from '../models/admin';
import AppError from '../utils/AppError'; // Correct import statement
import { firestore } from 'firebase-admin';

export class PermissionService {
    static async initializeDefaultPermissions(): Promise<void> {
        const batch = firestore().batch();

        for (const permission of defaultPermissions) {
            const docRef = permissionsCollection.doc(`${permission.role}_${permission.resource}`);
            batch.set(docRef, {
                ...permission,
                createdAt: firestore.FieldValue.serverTimestamp(),
                updatedAt: firestore.FieldValue.serverTimestamp()
            }, { merge: true });
        }

        await batch.commit();
    }

    static async hasPermission(
        role: AdminRole,
        resource: PermissionResource,
        action: PermissionAction
    ): Promise<boolean> {
        const docRef = await permissionsCollection.doc(`${role}_${resource}`).get();
        
        if (!docRef.exists) {
            return false;
        }

        const permission = docRef.data() as Permission;
        return permission.actions.includes(action);
    }

    static async getPermissionsByRole(role: AdminRole): Promise<Permission[]> {
        const snapshot = await permissionsCollection.where('role', '==', role).get();
        return snapshot.docs.map(doc => doc.data() as Permission);
    }

    static async addPermission(
        role: AdminRole,
        resource: PermissionResource,
        actions: PermissionAction[],
        description: string,
        conditions?: Record<string, any>
    ): Promise<Permission> {
        const docRef = permissionsCollection.doc(`${role}_${resource}`);
        const doc = await docRef.get();

        if (doc.exists) {
            throw new AppError('Permission already exists for this role and resource', 400); // Remove extra argument
        }

        const permission: Permission = {
            role,
            resource,
            actions,
            description,
            conditions,
            createdAt: firestore.Timestamp.now(),
            updatedAt: firestore.Timestamp.now()
        };

        await docRef.set(permission);
        return permission;
    }

    static async updatePermission(
        role: AdminRole,
        resource: PermissionResource,
        actions: PermissionAction[],
        description?: string,
        conditions?: Record<string, any>
    ): Promise<Permission | null> {
        const docRef = permissionsCollection.doc(`${role}_${resource}`);
        const doc = await docRef.get();

        if (!doc.exists) {
            return null;
        }

        const updateData: Partial<Permission> = {
            actions,
            updatedAt: firestore.Timestamp.now()
        };

        if (description) updateData.description = description;
        if (conditions) updateData.conditions = conditions;

        await docRef.update(updateData);
        
        const updatedDoc = await docRef.get();
        return updatedDoc.data() as Permission;
    }

    static async removePermission(
        role: AdminRole,
        resource: PermissionResource
    ): Promise<boolean> {
        const docRef = permissionsCollection.doc(`${role}_${resource}`);
        const doc = await docRef.get();

        if (!doc.exists) {
            return false;
        }

        await docRef.delete();
        return true;
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
    ): Promise<Permission[]> {
        const snapshot = await permissionsCollection.where('resource', '==', resource).get();
        return snapshot.docs.map(doc => doc.data() as Permission);
    }

    static async getRoleMatrix(): Promise<Record<AdminRole, Record<PermissionResource, PermissionAction[]>>> {
        const permissions = await permissionsCollection.get();
        const matrix: Record<AdminRole, Record<PermissionResource, PermissionAction[]>> = {} as any;

        for (const role of Object.values(AdminRole)) {
            matrix[role] = {} as Record<PermissionResource, PermissionAction[]>;
            for (const resource of Object.values(PermissionResource)) {
                const permission = permissions.docs.find(p => p.data().role === role && p.data().resource === resource);
                matrix[role][resource] = permission ? permission.data().actions : [];
            }
        }

        return matrix;
    }
}

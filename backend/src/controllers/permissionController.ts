import { Request, Response } from 'express';
import { db } from '../config/firebase';
import { PermissionService } from '../services/permissionService';
import { catchAsync } from '../utils/catchAsync';
import { AppError, errorCodes } from '../utils/errors';
import { AdminRole } from '../models/admin';
import { PermissionResource, PermissionAction } from '../models/permission';

export class PermissionController {
  initializePermissions = catchAsync(async (req: Request, res: Response) => {
    await PermissionService.initializeDefaultPermissions();
    
    res.status(200).json({
      status: 'success',
      message: 'Default permissions initialized successfully'
    });
  });

  getPermissionsByRole = catchAsync(async (req: Request, res: Response) => {
    const { role } = req.params;

    if (!Object.values(AdminRole).includes(role as AdminRole)) {
      throw new AppError(400, 'Invalid role', errorCodes.INVALID_ROLE); // Add error code
    }

    const permissions = await PermissionService.getPermissionsByRole(role as AdminRole);

    res.status(200).json({
      status: 'success',
      data: { permissions }
    });
  });

  addPermission = catchAsync(async (req: Request, res: Response) => {
    const { role, resource, actions, description, conditions } = req.body;

    // Validation
    if (!role || !resource || !actions || !description) {
      throw new AppError(400, 'Missing required fields', errorCodes.VALIDATION_ERROR); // Add error code
    }

    if (!Object.values(AdminRole).includes(role)) {
      throw new AppError(400, 'Invalid role', errorCodes.INVALID_ROLE); // Add error code
    }

    if (!Object.values(PermissionResource).includes(resource)) {
      throw new AppError(400, 'Invalid resource', errorCodes.INVALID_RESOURCE); // Add error code
    }

    if (!Array.isArray(actions) || !actions.every(action => 
      Object.values(PermissionAction).includes(action)
    )) {
      throw new AppError(400, 'Invalid actions', errorCodes.INVALID_ACTION); // Add error code
    }

    const permission = await PermissionService.addPermission(
      role,
      resource,
      actions,
      description,
      conditions
    );

    res.status(201).json({
      status: 'success',
      data: { permission }
    });
  });

  updatePermission = catchAsync(async (req: Request, res: Response) => {
    const { role, resource } = req.params;
    const { actions, description, conditions } = req.body;

    if (!Object.values(AdminRole).includes(role as AdminRole)) {
      throw new AppError(400, 'Invalid role', errorCodes.INVALID_ROLE); // Add error code
    }

    if (!Object.values(PermissionResource).includes(resource as PermissionResource)) {
      throw new AppError(400, 'Invalid resource', errorCodes.INVALID_RESOURCE); // Add error code
    }

    if (actions && (!Array.isArray(actions) || !actions.every(action => 
      Object.values(PermissionAction).includes(action)
    ))) {
      throw new AppError(400, 'Invalid actions', errorCodes.INVALID_ACTION); // Add error code
    }

    const permission = await PermissionService.updatePermission(
      role as AdminRole,
      resource as PermissionResource,
      actions,
      description,
      conditions
    );

    if (!permission) {
      throw new AppError(404, 'Permission not found', errorCodes.PERMISSION_NOT_FOUND); // Add error code
    }

    res.status(200).json({
      status: 'success',
      data: { permission }
    });
  });

  removePermission = catchAsync(async (req: Request, res: Response) => {
    const { role, resource } = req.params;

    if (!Object.values(AdminRole).includes(role as AdminRole)) {
      throw new AppError(400, 'Invalid role', errorCodes.INVALID_ROLE); // Add error code
    }

    if (!Object.values(PermissionResource).includes(resource as PermissionResource)) {
      throw new AppError(400, 'Invalid resource', errorCodes.INVALID_RESOURCE); // Add error code
    }

    const removed = await PermissionService.removePermission(
      role as AdminRole,
      resource as PermissionResource
    );

    if (!removed) {
      throw new AppError(404, 'Permission not found', errorCodes.PERMISSION_NOT_FOUND); // Add error code
    }

    res.status(200).json({
      status: 'success',
      message: 'Permission removed successfully'
    });
  });

  getRoleMatrix = catchAsync(async (req: Request, res: Response) => {
    const matrix = await PermissionService.getRoleMatrix();

    res.status(200).json({
      status: 'success',
      data: { matrix }
    });
  });

  getResourcePermissions = catchAsync(async (req: Request, res: Response) => {
    const { resource } = req.params;

    if (!Object.values(PermissionResource).includes(resource as PermissionResource)) {
      throw new AppError(400, 'Invalid resource', errorCodes.INVALID_RESOURCE); // Add error code
    }

    const permissions = await PermissionService.getResourcePermissions(
      resource as PermissionResource
    );

    res.status(200).json({
      status: 'success',
      data: { permissions }
    });
  });

  async getAllPermissions(req: Request, res: Response) {
    try {
      const permissionsSnapshot = await db.collection('permissions').get();
      const permissions = permissionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json(permissions);
    } catch (error) {
      console.error('Error getting permissions:', error);
      res.status(500).json({ error: 'Failed to retrieve permissions' });
    }
  }

  async getPermissionById(req: Request, res: Response) {
    try {
      const permissionDoc = await db.collection('permissions').doc(req.params.id).get();
      
      if (!permissionDoc.exists) {
        return res.status(404).json({ error: 'Permission not found' });
      }

      res.json({
        id: permissionDoc.id,
        ...permissionDoc.data()
      });
    } catch (error) {
      console.error('Error getting permission:', error);
      res.status(500).json({ error: 'Failed to retrieve permission' });
    }
  }

  async createPermission(req: Request, res: Response) {
    try {
      const { name, description, actions } = req.body;
      const permissionRef = db.collection('permissions').doc();
      const now = new Date();

      await permissionRef.set({
        id: permissionRef.id,
        name,
        description,
        actions,
        createdAt: now,
        updatedAt: now
      });

      res.status(201).json({
        id: permissionRef.id,
        message: 'Permission created successfully'
      });
    } catch (error) {
      console.error('Error creating permission:', error);
      res.status(500).json({ error: 'Failed to create permission' });
    }
  }

  async updatePermissionById(req: Request, res: Response) {
    try {
      const { name, description, actions } = req.body;
      const permissionRef = db.collection('permissions').doc(req.params.id);
      
      const permissionDoc = await permissionRef.get();
      if (!permissionDoc.exists) {
        return res.status(404).json({ error: 'Permission not found' });
      }

      await permissionRef.update({
        name,
        description,
        actions,
        updatedAt: new Date()
      });

      res.json({
        id: permissionRef.id,
        message: 'Permission updated successfully'
      });
    } catch (error) {
      console.error('Error updating permission:', error);
      res.status(500).json({ error: 'Failed to update permission' });
    }
  }

  async deletePermission(req: Request, res: Response) {
    try {
      const permissionRef = db.collection('permissions').doc(req.params.id);
      
      const permissionDoc = await permissionRef.get();
      if (!permissionDoc.exists) {
        return res.status(404).json({ error: 'Permission not found' });
      }

      await permissionRef.delete();

      res.json({
        message: 'Permission deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting permission:', error);
      res.status(500).json({ error: 'Failed to delete permission' });
    }
  }

  async getRolePermissions(req: Request, res: Response) {
    try {
      const { roleId } = req.params;
      const rolePermissionsSnapshot = await db.collection('role_permissions')
        .where('roleId', '==', roleId)
        .get();

      const rolePermissions = rolePermissionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json(rolePermissions);
    } catch (error) {
      console.error('Error getting role permissions:', error);
      res.status(500).json({ error: 'Failed to retrieve role permissions' });
    }
  }

  async assignPermissionToRole(req: Request, res: Response) {
    try {
      const { roleId } = req.params;
      const { permissionId } = req.body;

      const rolePermissionRef = db.collection('role_permissions').doc();
      const now = new Date();

      await rolePermissionRef.set({
        id: rolePermissionRef.id,
        roleId,
        permissionId,
        createdAt: now,
        updatedAt: now
      });

      res.status(201).json({
        id: rolePermissionRef.id,
        message: 'Permission assigned to role successfully'
      });
    } catch (error) {
      console.error('Error assigning permission to role:', error);
      res.status(500).json({ error: 'Failed to assign permission to role' });
    }
  }

  async removePermissionFromRole(req: Request, res: Response) {
    try {
      const { roleId, permissionId } = req.params;
      const rolePermissionSnapshot = await db.collection('role_permissions')
        .where('roleId', '==', roleId)
        .where('permissionId', '==', permissionId)
        .get();

      if (rolePermissionSnapshot.empty) {
        return res.status(404).json({ error: 'Role permission not found' });
      }

      await rolePermissionSnapshot.docs[0].ref.delete();

      res.json({
        message: 'Permission removed from role successfully'
      });
    } catch (error) {
      console.error('Error removing permission from role:', error);
      res.status(500).json({ error: 'Failed to remove permission from role' });
    }
  }
}

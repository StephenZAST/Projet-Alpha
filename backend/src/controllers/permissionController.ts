import { Request, Response } from 'express';
import { PermissionService } from '../services/permissionService';
import { catchAsync } from '../utils/catchAsync';
import { AppError } from '../utils/errors';
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
            throw new AppError(400, 'Invalid role');
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
            throw new AppError(400, 'Missing required fields');
        }

        if (!Object.values(AdminRole).includes(role)) {
            throw new AppError(400, 'Invalid role');
        }

        if (!Object.values(PermissionResource).includes(resource)) {
            throw new AppError(400, 'Invalid resource');
        }

        if (!Array.isArray(actions) || !actions.every(action => 
            Object.values(PermissionAction).includes(action)
        )) {
            throw new AppError(400, 'Invalid actions');
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
            throw new AppError(400, 'Invalid role');
        }

        if (!Object.values(PermissionResource).includes(resource as PermissionResource)) {
            throw new AppError(400, 'Invalid resource');
        }

        if (actions && (!Array.isArray(actions) || !actions.every(action => 
            Object.values(PermissionAction).includes(action)
        ))) {
            throw new AppError(400, 'Invalid actions');
        }

        const permission = await PermissionService.updatePermission(
            role as AdminRole,
            resource as PermissionResource,
            actions,
            description,
            conditions
        );

        if (!permission) {
            throw new AppError(404, 'Permission not found');
        }

        res.status(200).json({
            status: 'success',
            data: { permission }
        });
    });

    removePermission = catchAsync(async (req: Request, res: Response) => {
        const { role, resource } = req.params;

        if (!Object.values(AdminRole).includes(role as AdminRole)) {
            throw new AppError(400, 'Invalid role');
        }

        if (!Object.values(PermissionResource).includes(resource as PermissionResource)) {
            throw new AppError(400, 'Invalid resource');
        }

        const removed = await PermissionService.removePermission(
            role as AdminRole,
            resource as PermissionResource
        );

        if (!removed) {
            throw new AppError(404, 'Permission not found');
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
            throw new AppError(400, 'Invalid resource');
        }

        const permissions = await PermissionService.getResourcePermissions(
            resource as PermissionResource
        );

        res.status(200).json({
            status: 'success',
            data: { permissions }
        });
    });
}

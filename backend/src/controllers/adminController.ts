import { Request, Response } from 'express';
import { AdminService } from '../services/adminService';
import { AppError, errorCodes } from '../utils/errors'; // Import errorCodes
import { AdminRole } from '../models/admin';

export class AdminController {
    private adminService: AdminService;

    constructor() {
        this.adminService = new AdminService();
    }

    // Connexion admin
    login = async (req: Request, res: Response) => {
        try {
            const { email, password } = req.body;
            const result = await this.adminService.loginAdmin(email, password);
            
            res.json({
                success: true,
                data: {
                    admin: result.admin,
                    token: result.token
                }
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };

    // Créer un nouvel admin
    createAdmin = async (req: Request, res: Response) => {
        try {
            const creatorId = req.user?.id; // Optional chaining for req.user
            if (!creatorId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }
            const adminData = req.body;
            
            const admin = await this.adminService.createAdmin(adminData, creatorId);
            
            res.status(201).json({
                success: true,
                data: admin
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };

    // Mettre à jour un admin
    updateAdmin = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const updates = req.body;
            const updaterId = req.user?.id; // Optional chaining for req.user
            if (!updaterId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }

            const admin = await this.adminService.updateAdmin(id, updates, updaterId);
            
            res.json({
                success: true,
                data: admin
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };

    // Supprimer un admin
    deleteAdmin = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const deleterId = req.user?.id; // Optional chaining for req.user
            if (!deleterId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }

            await this.adminService.deleteAdmin(id, deleterId);
            
            res.json({
                success: true,
                message: "Administrateur supprimé avec succès"
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };

    // Obtenir tous les admins
    getAllAdmins = async (req: Request, res: Response) => {
        try {
            const requesterId = req.user?.id; // Optional chaining for req.user
            if (!requesterId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }
            const admins = await this.adminService.getAllAdmins(requesterId);
            
            res.json({
                success: true,
                data: admins
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };

    // Obtenir un admin par ID
    getAdminById = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const requesterId = req.user?.id; // Optional chaining for req.user
            if (!requesterId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }

            const admin = await this.adminService.getAdminById(id, requesterId);
            
            res.json({
                success: true,
                data: admin
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };

    // Changer le statut d'un admin
    toggleAdminStatus = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const { isActive } = req.body;
            const requesterId = req.user?.id; // Optional chaining for req.user
            if (!requesterId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }

            const admin = await this.adminService.toggleAdminStatus(id, isActive, requesterId);
            
            res.json({
                success: true,
                data: admin
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };

    // Créer le compte Super Admin Master (endpoint protégé et à usage unique)
    createMasterAdmin = async (req: Request, res: Response) => {
        try {
            const adminData = req.body;
            const admin = await this.adminService.createMasterAdmin(adminData);
            
            res.status(201).json({
                success: true,
                data: admin
            });
        } catch (error) {
            if (error instanceof AppError) { // Check if error is an instance of AppError
                res.status(error.statusCode || 500).json({
                    success: false,
                    message: error.message
                });
            } else {
                res.status(500).json({
                    success: false,
                    message: 'Internal Server Error'
                });
            }
        }
    };
}

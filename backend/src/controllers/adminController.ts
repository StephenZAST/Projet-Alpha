import { Request, Response } from 'express';
import { AdminService } from '../services/adminService';
import { AppError } from '../utils/errors';
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
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Créer un nouvel admin
    createAdmin = async (req: Request, res: Response) => {
        try {
            const creatorId = req.user.id; // Fourni par le middleware d'authentification
            const adminData = req.body;
            
            const admin = await this.adminService.createAdmin(adminData, creatorId);
            
            res.status(201).json({
                success: true,
                data: admin
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Mettre à jour un admin
    updateAdmin = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const updates = req.body;
            const updaterId = req.user.id;

            const admin = await this.adminService.updateAdmin(id, updates, updaterId);
            
            res.json({
                success: true,
                data: admin
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Supprimer un admin
    deleteAdmin = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const deleterId = req.user.id;

            await this.adminService.deleteAdmin(id, deleterId);
            
            res.json({
                success: true,
                message: "Administrateur supprimé avec succès"
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Obtenir tous les admins
    getAllAdmins = async (req: Request, res: Response) => {
        try {
            const requesterId = req.user.id;
            const admins = await this.adminService.getAllAdmins(requesterId);
            
            res.json({
                success: true,
                data: admins
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Obtenir un admin par ID
    getAdminById = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const requesterId = req.user.id;

            const admin = await this.adminService.getAdminById(id, requesterId);
            
            res.json({
                success: true,
                data: admin
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Changer le statut d'un admin
    toggleAdminStatus = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const { isActive } = req.body;
            const requesterId = req.user.id;

            const admin = await this.adminService.toggleAdminStatus(id, isActive, requesterId);
            
            res.json({
                success: true,
                data: admin
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
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
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };
}

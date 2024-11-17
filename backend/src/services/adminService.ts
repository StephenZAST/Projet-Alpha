import { Admin, AdminRole, IAdmin } from '../models/admin';
import { hashPassword, comparePassword } from '../utils/auth';
import { generateToken } from '../utils/jwt';
import { AppError } from '../utils/errors';

export class AdminService {
    // Créer un compte admin (uniquement par super admin)
    async createAdmin(adminData: Partial<IAdmin>, creatorId: string): Promise<IAdmin> {
        const creator = await Admin.findById(creatorId);
        if (!creator || (creator.role !== AdminRole.SUPER_ADMIN_MASTER && creator.role !== AdminRole.SUPER_ADMIN)) {
            throw new AppError(403, "Non autorisé à créer des administrateurs");
        }

        // Vérifier si c'est une tentative de création d'un super admin master
        if (adminData.role === AdminRole.SUPER_ADMIN_MASTER) {
            throw new AppError(403, "Impossible de créer un autre Super Admin Master");
        }

        // Pour la création d'un super admin, seul le master peut le faire
        if (adminData.role === AdminRole.SUPER_ADMIN && creator.role !== AdminRole.SUPER_ADMIN_MASTER) {
            throw new AppError(403, "Seul le Super Admin Master peut créer d'autres Super Admins");
        }

        const hashedPassword = await hashPassword(adminData.password);
        
        const admin = new Admin({
            ...adminData,
            password: hashedPassword,
            createdBy: creatorId
        });

        return await admin.save();
    }

    // Connexion admin
    async loginAdmin(email: string, password: string): Promise<{ admin: IAdmin; token: string }> {
        const admin = await Admin.findOne({ email });
        if (!admin || !admin.isActive) {
            throw new AppError(401, "Email ou mot de passe incorrect");
        }

        const isValidPassword = await comparePassword(password, admin.password);
        if (!isValidPassword) {
            throw new AppError(401, "Email ou mot de passe incorrect");
        }

        admin.lastLogin = new Date();
        await admin.save();

        const token = generateToken(admin);

        return { admin, token };
    }

    // Mettre à jour un admin
    async updateAdmin(adminId: string, updates: Partial<IAdmin>, updaterId: string): Promise<IAdmin> {
        const updater = await Admin.findById(updaterId);
        const adminToUpdate = await Admin.findById(adminId);

        if (!updater || !adminToUpdate) {
            throw new AppError(404, "Administrateur non trouvé");
        }

        // Vérifications de sécurité
        if (adminToUpdate.isMasterAdmin) {
            throw new AppError(403, "Le compte Master Admin ne peut pas être modifié");
        }

        if (updates.role === AdminRole.SUPER_ADMIN_MASTER) {
            throw new AppError(403, "Impossible de promouvoir en Super Admin Master");
        }

        // Seul le master peut modifier un super admin
        if (adminToUpdate.role === AdminRole.SUPER_ADMIN && updater.role !== AdminRole.SUPER_ADMIN_MASTER) {
            throw new AppError(403, "Seul le Super Admin Master peut modifier un Super Admin");
        }

        if (updates.password) {
            updates.password = await hashPassword(updates.password);
        }

        const updatedAdmin = await Admin.findByIdAndUpdate(
            adminId,
            { ...updates },
            { new: true }
        );

        return updatedAdmin;
    }

    // Supprimer un admin
    async deleteAdmin(adminId: string, deleterId: string): Promise<void> {
        const deleter = await Admin.findById(deleterId);
        const adminToDelete = await Admin.findById(adminId);

        if (!deleter || !adminToDelete) {
            throw new AppError(404, "Administrateur non trouvé");
        }

        // Vérifications de sécurité
        if (adminToDelete.isMasterAdmin) {
            throw new AppError(403, "Le compte Master Admin ne peut pas être supprimé");
        }

        if (adminToDelete.role === AdminRole.SUPER_ADMIN && deleter.role !== AdminRole.SUPER_ADMIN_MASTER) {
            throw new AppError(403, "Seul le Super Admin Master peut supprimer un Super Admin");
        }

        await Admin.deleteOne({ _id: adminId });
    }

    // Obtenir tous les admins (pour super admin uniquement)
    async getAllAdmins(requesterId: string): Promise<IAdmin[]> {
        const requester = await Admin.findById(requesterId);
        if (!requester || (requester.role !== AdminRole.SUPER_ADMIN_MASTER && requester.role !== AdminRole.SUPER_ADMIN)) {
            throw new AppError(403, "Non autorisé à voir tous les administrateurs");
        }

        return await Admin.find().select('-password');
    }

    // Obtenir un admin par ID
    async getAdminById(adminId: string, requesterId: string): Promise<IAdmin> {
        const requester = await Admin.findById(requesterId);
        const admin = await Admin.findById(adminId).select('-password');

        if (!requester || !admin) {
            throw new AppError(404, "Administrateur non trouvé");
        }

        // Seuls les super admins peuvent voir les détails des autres admins
        if (requesterId !== adminId && 
            requester.role !== AdminRole.SUPER_ADMIN_MASTER && 
            requester.role !== AdminRole.SUPER_ADMIN) {
            throw new AppError(403, "Non autorisé à voir les détails de cet administrateur");
        }

        return admin;
    }

    // Changer le statut actif/inactif d'un admin
    async toggleAdminStatus(adminId: string, isActive: boolean, requesterId: string): Promise<IAdmin> {
        const requester = await Admin.findById(requesterId);
        const adminToUpdate = await Admin.findById(adminId);

        if (!requester || !adminToUpdate) {
            throw new AppError(404, "Administrateur non trouvé");
        }

        if (adminToUpdate.isMasterAdmin) {
            throw new AppError(403, "Le compte Master Admin ne peut pas être désactivé");
        }

        if (adminToUpdate.role === AdminRole.SUPER_ADMIN && requester.role !== AdminRole.SUPER_ADMIN_MASTER) {
            throw new AppError(403, "Seul le Super Admin Master peut modifier le statut d'un Super Admin");
        }

        adminToUpdate.isActive = isActive;
        return await adminToUpdate.save();
    }

    // Créer le compte Super Admin Master initial (ne devrait être utilisé qu'une fois)
    async createMasterAdmin(adminData: Partial<IAdmin>): Promise<IAdmin> {
        const existingMaster = await Admin.findOne({ isMasterAdmin: true });
        if (existingMaster) {
            throw new AppError(403, "Un Super Admin Master existe déjà");
        }

        const hashedPassword = await hashPassword(adminData.password);
        
        const masterAdmin = new Admin({
            ...adminData,
            role: AdminRole.SUPER_ADMIN_MASTER,
            isMasterAdmin: true,
            password: hashedPassword,
            createdBy: 'SYSTEM'
        });

        return await masterAdmin.save();
    }
}

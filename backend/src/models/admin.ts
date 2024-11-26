import { db } from '../config/firebase';
import { AppError, errorCodes } from '../utils/errors';

export enum AdminRole {
    SUPER_ADMIN_MASTER = 'super_admin_master', // Votre compte unique
    SUPER_ADMIN = 'super_admin',               // Super admins secondaires
    SECRETARY = 'secretary',
    DELIVERY = 'delivery',
    CUSTOMER_SERVICE = 'customer_service',
    SUPERVISOR = 'supervisor'
}

// Define IAdmin interface before adminSchema
export interface IAdmin {
    _id: string; // Added _id property
    userId: string;
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    role: AdminRole;
    phoneNumber: string;
    isActive: boolean;
    createdBy: string;      // Change createdBy type to string
    lastLogin?: Date;
    createdAt: Date;
    updatedAt: Date;
    permissions: string[];  // Liste des permissions spécifiques
    isMasterAdmin: boolean; // Pour identifier le super admin principal
}

// Use Firebase Firestore to store admin data
const adminsRef = db.collection('admins');

// Function to get admin data
export async function getAdmin(userId: string): Promise<IAdmin | null> {
    const adminDoc = await adminsRef.doc(userId).get();
    if (!adminDoc.exists) {
        return null;
    }
    return adminDoc.data() as IAdmin;
}

// Function to create admin
export async function createAdmin(adminData: IAdmin): Promise<IAdmin> {
    // Check if master admin already exists
    if (adminData.isMasterAdmin) {
        const masterAdmin = await adminsRef.where('isMasterAdmin', '==', true).get();
        if (!masterAdmin.empty) {
            throw new AppError(400, 'A master admin already exists', errorCodes.MASTER_ADMIN_EXISTS);
        }
    }

    const adminRef = await adminsRef.add(adminData);
    return adminRef.get().then(doc => doc.data() as IAdmin);
}

// Function to update admin
export async function updateAdmin(userId: string, adminData: Partial<IAdmin>): Promise<IAdmin> {
    const adminRef = adminsRef.doc(userId);
    const currentAdmin = await getAdmin(userId);

    if (!currentAdmin) {
        throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }

    // Prevent modification of master admin status
    if (adminData.isMasterAdmin !== undefined && currentAdmin.isMasterAdmin) {
        throw new AppError(400, 'Cannot modify master admin status', errorCodes.MASTER_ADMIN_MODIFICATION);
    }

    await adminRef.update(adminData);
    return adminRef.get().then(doc => doc.data() as IAdmin);
}

// Function to delete admin
export async function deleteAdmin(userId: string): Promise<void> {
    const admin = await getAdmin(userId);

    if (!admin) {
        throw new AppError(404, 'Admin not found', errorCodes.ADMIN_NOT_FOUND);
    }

    // Prevent deletion of master admin
    if (admin.isMasterAdmin) {
        throw new AppError(400, 'Cannot delete master admin', errorCodes.MASTER_ADMIN_DELETION);
    }

    await adminsRef.doc(userId).delete();
}

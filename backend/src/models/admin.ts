import { Schema, model, Document, Types } from 'mongoose'; // Import Types

export enum AdminRole {
    SUPER_ADMIN_MASTER = 'super_admin_master', // Votre compte unique
    SUPER_ADMIN = 'super_admin',               // Super admins secondaires
    SECRETARY = 'secretary',
    DELIVERY = 'delivery',
    CUSTOMER_SERVICE = 'customer_service',
    SUPERVISOR = 'supervisor'
}

// Define IAdmin interface before adminSchema
export interface IAdmin extends Document {
    userId: string;
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    role: AdminRole;
    phoneNumber: string;
    isActive: boolean;
    createdBy: Types.ObjectId;      // Change createdBy type to Types.ObjectId
    lastLogin?: Date;
    createdAt: Date;
    updatedAt: Date;
    permissions: string[];  // Liste des permissions spécifiques
    isMasterAdmin: boolean; // Pour identifier le super admin principal
}

const adminSchema = new Schema<IAdmin>({
    userId: {
        type: String,
        required: true,
        unique: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    firstName: {
        type: String,
        required: true
    },
    lastName: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: Object.values(AdminRole),
        required: true
    },
    phoneNumber: {
        type: String,
        required: true
    },
    isActive: {
        type: Boolean,
        default: true
    },
    createdBy: {
        type: Schema.Types.ObjectId,
        ref: 'Admin',
        required: true
    },
    lastLogin: {
        type: Date
    },
    permissions: [{
        type: String
    }],
    isMasterAdmin: {
        type: Boolean,
        default: false
    }
}, {
    timestamps: true
});

// Middleware pour empêcher la suppression du Master Admin
adminSchema.pre('deleteOne', async function(next) {
    const adminId = this.getQuery()["_id"];
    const admin = await this.model.findOne({ _id: adminId });
    
    if (admin?.isMasterAdmin) {
        throw new Error("Le compte Master Admin ne peut pas être supprimé");
    }
    next();
});

// Middleware pour empêcher la modification du rôle du Master Admin
adminSchema.pre('save', function(next) {
    // Type cast this to IAdmin
    const admin = this as IAdmin; 
    if (admin.isModified('isMasterAdmin') && admin.isMasterAdmin) {
        throw new Error("Le statut Master Admin ne peut pas être modifié");
    }
    next();
});

export const Admin = model<IAdmin>('Admin', adminSchema);

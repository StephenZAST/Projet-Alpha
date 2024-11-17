import mongoose, { Schema, Document } from 'mongoose';
import { IAdmin } from './admin';

export enum AdminAction {
    LOGIN = 'LOGIN',
    LOGOUT = 'LOGOUT',
    CREATE_ADMIN = 'CREATE_ADMIN',
    UPDATE_ADMIN = 'UPDATE_ADMIN',
    DELETE_ADMIN = 'DELETE_ADMIN',
    TOGGLE_STATUS = 'TOGGLE_STATUS',
    FAILED_LOGIN = 'FAILED_LOGIN'
}

export interface IAdminLog extends Document {
    adminId: IAdmin['_id'];
    action: AdminAction;
    targetAdminId?: IAdmin['_id'];
    details: string;
    ipAddress: string;
    userAgent: string;
    createdAt: Date;
}

const adminLogSchema = new Schema({
    adminId: {
        type: Schema.Types.ObjectId,
        ref: 'Admin',
        required: true
    },
    action: {
        type: String,
        enum: Object.values(AdminAction),
        required: true
    },
    targetAdminId: {
        type: Schema.Types.ObjectId,
        ref: 'Admin'
    },
    details: {
        type: String,
        required: true
    },
    ipAddress: {
        type: String,
        required: true
    },
    userAgent: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Index pour une recherche rapide
adminLogSchema.index({ adminId: 1, createdAt: -1 });
adminLogSchema.index({ action: 1, createdAt: -1 });

export const AdminLog = mongoose.model<IAdminLog>('AdminLog', adminLogSchema);

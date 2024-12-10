import { db, Timestamp } from '../../config/firebase';
import { Affiliate, AffiliateStatus } from '../../models/affiliate';
import { CodeGenerator } from '../../utils/codeGenerator';
import { AppError, errorCodes } from '../../utils/errors';
import { notificationService, NotificationType, NotificationStatus } from '../notificationService';

const affiliatesRef = db.collection('affiliates');

export async function createAffiliate(
    firstName: string,
    lastName: string,
    email: string,
    phoneNumber: string,
    address: string,
    orderPreferences: Affiliate['orderPreferences'],
    paymentInfo: Affiliate['paymentInfo']
): Promise<Affiliate> {
    try {
        // Check if email is already used
        const existingAffiliate = await affiliatesRef
            .where('email', '==', email)
            .get();

        if (!existingAffiliate.empty) {
            throw new AppError(400, 'Email already registered as affiliate', errorCodes.EMAIL_ALREADY_REGISTERED);
        }

        const affiliate: Omit<Affiliate, 'id'> = {
            firstName,
            lastName,
            email,
            phoneNumber,
            address,
            orderPreferences,
            status: AffiliateStatus.PENDING,
            paymentInfo,
            commissionRate: 10, // 10% default
            totalEarnings: 0,
            availableBalance: 0,
            referralCode: await CodeGenerator.generateAffiliateCode(),
            referralClicks: 0,
            createdAt: new Date(),
            updatedAt: new Date()
        };

        const docRef = await affiliatesRef.add(affiliate);
        return { ...affiliate, id: docRef.id } as Affiliate;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to create affiliate', errorCodes.AFFILIATE_CREATION_FAILED);
    }
}

export async function approveAffiliate(affiliateId: string): Promise<void> {
    try {
        const affiliateRef = affiliatesRef.doc(affiliateId);
        const affiliate = await affiliateRef.get();

        if (!affiliate.exists) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        if (affiliate.data()?.status === AffiliateStatus.ACTIVE) {
            throw new AppError(400, 'Affiliate is already active', errorCodes.AFFILIATE_ALREADY_ACTIVE);
        }

        await affiliateRef.update({
            status: AffiliateStatus.ACTIVE,
            updatedAt: Timestamp.now()
        });

        // Notify affiliate
        await notificationService.createNotification({
            userId: affiliateId,
            title: 'Affiliate Application Approved',
            message: 'Your affiliate application has been approved. You can now start referring customers.',
            type: NotificationType.AFFILIATE_APPROVED,
            status: NotificationStatus.UNREAD
        });
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to approve affiliate', errorCodes.AFFILIATE_UPDATE_FAILED);
    }
}

export async function getAffiliateProfile(affiliateId: string): Promise<Affiliate> {
    try {
        const affiliateDoc = await affiliatesRef.doc(affiliateId).get();

        if (!affiliateDoc.exists) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        return { id: affiliateDoc.id, ...affiliateDoc.data() } as Affiliate;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to fetch affiliate profile', errorCodes.AFFILIATE_FETCH_FAILED);
    }
}

export async function updateProfile(affiliateId: string, updates: Partial<Omit<Affiliate, 'id' | 'status' | 'referralCode'>>): Promise<void> {
    try {
        const affiliateRef = affiliatesRef.doc(affiliateId);
        const affiliate = await affiliateRef.get();

        if (!affiliate.exists) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        await affiliateRef.update({
            ...updates,
            updatedAt: Timestamp.now()
        });
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to update affiliate profile', errorCodes.AFFILIATE_UPDATE_FAILED);
    }
}

export async function getPendingAffiliates(): Promise<Affiliate[]> {
    try {
        const snapshot = await affiliatesRef
            .where('status', '==', AffiliateStatus.PENDING)
            .orderBy('createdAt', 'desc')
            .get();

        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        })) as Affiliate[];
    } catch (error) {
        throw new AppError(500, 'Failed to fetch pending affiliates', errorCodes.AFFILIATE_FETCH_FAILED);
    }
}

export async function getAllAffiliates(): Promise<Affiliate[]> {
    try {
        const snapshot = await affiliatesRef
            .orderBy('createdAt', 'desc')
            .get();

        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        })) as Affiliate[];
    } catch (error) {
        throw new AppError(500, 'Failed to fetch all affiliates', errorCodes.AFFILIATE_FETCH_FAILED);
    }
}

export async function getAffiliateById(affiliateId: string): Promise<Affiliate> {
    try {
        const affiliateDoc = await affiliatesRef.doc(affiliateId).get();

        if (!affiliateDoc.exists) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        return { id: affiliateDoc.id, ...affiliateDoc.data() } as Affiliate;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to get affiliate', errorCodes.AFFILIATE_NOT_FOUND);
    }
}

export async function deleteAffiliate(affiliateId: string): Promise<void> {
    try {
        const affiliateRef = affiliatesRef.doc(affiliateId);
        const affiliateDoc = await affiliateRef.get();

        if (!affiliateDoc.exists) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        // Delete the affiliate
        await affiliateRef.delete();

        // Delete associated commissions
        const commissionsSnapshot = await db.collection('commissions').where('affiliateId', '==', affiliateId).get();
        const commissionsDeletePromises = commissionsSnapshot.docs.map(doc => doc.ref.delete());
        await Promise.all(commissionsDeletePromises);

        // Delete associated withdrawal requests
        const withdrawalsSnapshot = await db.collection('commission-withdrawals').where('affiliateId', '==', affiliateId).get();
        const withdrawalsDeletePromises = withdrawalsSnapshot.docs.map(doc => doc.ref.delete());
        await Promise.all(withdrawalsDeletePromises);

        // TODO: Consider deleting associated notifications

    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to delete affiliate', errorCodes.AFFILIATE_DELETION_FAILED);
    }
}

export async function updateAffiliate(affiliateId: string, affiliateData: Partial<Affiliate>): Promise<Affiliate> {
    try {
        const affiliateRef = affiliatesRef.doc(affiliateId);
        const affiliateDoc = await affiliateRef.get();

        if (!affiliateDoc.exists) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        await affiliateRef.update({
            ...affiliateData,
            updatedAt: Timestamp.now()
        });

        return {
            id: affiliateId,
            ...affiliateDoc.data(),
            ...affiliateData,
            updatedAt: new Date()
        } as Affiliate;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to update affiliate', errorCodes.AFFILIATE_UPDATE_FAILED);
    }
}

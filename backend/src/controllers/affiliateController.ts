import { Request, Response } from 'express';
import { AffiliateService } from '../services/affiliateService';
import { CommissionService } from '../services/commissionService';
import { AppError } from '../utils/errors';
import { PaymentMethod } from '../models/affiliate';

export class AffiliateController {
    private affiliateService: AffiliateService;
    private commissionService: CommissionService;

    constructor() {
        this.affiliateService = new AffiliateService();
        this.commissionService = new CommissionService();
    }

    // Inscription d'un nouvel affilié
    register = async (req: Request, res: Response) => {
        try {
            const { fullName, email, phone, paymentInfo } = req.body;

            if (!fullName || !email || !phone || !paymentInfo) {
                throw new AppError(400, 'Missing required fields');
            }

            const affiliate = await this.affiliateService.createAffiliate(
                fullName,
                email,
                phone,
                paymentInfo
            );

            res.status(201).json({
                success: true,
                data: affiliate
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Obtenir le profil de l'affilié
    getProfile = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user.id; // Fourni par le middleware d'authentification
            const affiliate = await this.affiliateService.getAffiliateProfile(affiliateId);

            res.json({
                success: true,
                data: affiliate
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Mettre à jour le profil
    updateProfile = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user.id;
            const updates = req.body;

            await this.affiliateService.updateProfile(affiliateId, updates);

            res.json({
                success: true,
                message: 'Profile updated successfully'
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Obtenir les statistiques de l'affilié
    getStats = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user.id;
            const stats = await this.affiliateService.getAffiliateStats(affiliateId);

            res.json({
                success: true,
                data: stats
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Demande de retrait
    requestWithdrawal = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user.id;
            const { amount, paymentMethod } = req.body;

            if (!amount || !paymentMethod) {
                throw new AppError(400, 'Amount and payment method are required');
            }

            const withdrawal = await this.affiliateService.requestWithdrawal(
                affiliateId,
                amount,
                paymentMethod as PaymentMethod
            );

            res.status(201).json({
                success: true,
                data: withdrawal
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Historique des retraits
    getWithdrawalHistory = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user.id;
            const withdrawals = await this.affiliateService.getWithdrawalHistory(affiliateId);

            res.json({
                success: true,
                data: withdrawals
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Routes admin/secrétaire

    // Obtenir les affiliés en attente
    getPendingAffiliates = async (req: Request, res: Response) => {
        try {
            const pendingAffiliates = await this.affiliateService.getPendingAffiliates();

            res.json({
                success: true,
                data: pendingAffiliates
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Approuver un affilié
    approveAffiliate = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            await this.affiliateService.approveAffiliate(id);

            res.json({
                success: true,
                message: 'Affiliate approved successfully'
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Obtenir les retraits en attente
    getPendingWithdrawals = async (req: Request, res: Response) => {
        try {
            const pendingWithdrawals = await this.affiliateService.getPendingWithdrawals();

            res.json({
                success: true,
                data: pendingWithdrawals
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Traiter un retrait
    processWithdrawal = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const { status, notes } = req.body;
            const adminId = req.user.id;

            await this.affiliateService.processWithdrawal(id, adminId, status, notes);

            res.json({
                success: true,
                message: 'Withdrawal processed successfully'
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Routes admin uniquement

    // Obtenir tous les affiliés
    getAllAffiliates = async (req: Request, res: Response) => {
        try {
            const affiliates = await this.affiliateService.getAllAffiliates();

            res.json({
                success: true,
                data: affiliates
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Mettre à jour les règles de commission
    updateCommissionRules = async (req: Request, res: Response) => {
        try {
            const { ruleId, updates } = req.body;
            await this.commissionService.updateCommissionRule(ruleId, updates);

            res.json({
                success: true,
                message: 'Commission rules updated successfully'
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };

    // Obtenir les analytics
    getAnalytics = async (req: Request, res: Response) => {
        try {
            const analytics = await this.affiliateService.getAnalytics();

            res.json({
                success: true,
                data: analytics
            });
        } catch (error) {
            res.status(error.statusCode || 500).json({
                success: false,
                message: error.message
            });
        }
    };
}

import { Request, Response } from 'express';
import { AffiliateService } from '../services/affiliateService';
import { CommissionService } from '../services/commissionService';
import { AppError, errorCodes } from '../utils/errors';
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
                throw new AppError(400, 'Missing required fields', errorCodes.VALIDATION_ERROR); // Add error code
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
            if (error instanceof AppError) {
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

    // Placeholder for login
    login = async (req: Request, res: Response) => {
        // TODO: Implement login logic
        res.status(501).json({
            success: false,
            message: 'Login not implemented yet'
        });
    };

    // Obtenir le profil de l'affilié
    getProfile = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user?.id; // Optional chaining for req.user
            if (!affiliateId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }
            const affiliate = await this.affiliateService.getAffiliateProfile(affiliateId);

            res.json({
                success: true,
                data: affiliate
            });
        } catch (error) {
            if (error instanceof AppError) {
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

    // Mettre à jour le profil
    updateProfile = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user?.id; // Optional chaining for req.user
            if (!affiliateId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }

            const updates = req.body;

            await this.affiliateService.updateProfile(affiliateId, updates);

            res.json({
                success: true,
                message: 'Profile updated successfully'
            });
        } catch (error) {
            if (error instanceof AppError) {
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

    // Obtenir les statistiques de l'affilié
    getStats = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user?.id; // Optional chaining for req.user
            if (!affiliateId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }
            const stats = await this.affiliateService.getAffiliateStats(affiliateId);

            res.json({
                success: true,
                data: stats
            });
        } catch (error) {
            if (error instanceof AppError) {
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

    // Demande de retrait
    requestWithdrawal = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user?.id; // Optional chaining for req.user
            if (!affiliateId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }
            const { amount, paymentMethod } = req.body;

            if (!amount || !paymentMethod) {
                throw new AppError(400, 'Amount and payment method are required', errorCodes.VALIDATION_ERROR); // Add error code
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
            if (error instanceof AppError) {
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

    // Historique des retraits
    getWithdrawalHistory = async (req: Request, res: Response) => {
        try {
            const affiliateId = req.user?.id; // Optional chaining for req.user
            if (!affiliateId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }
            const withdrawals = await this.affiliateService.getWithdrawalHistory(affiliateId);

            res.json({
                success: true,
                data: withdrawals
            });
        } catch (error) {
            if (error instanceof AppError) {
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
            if (error instanceof AppError) {
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
            if (error instanceof AppError) {
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

    // Obtenir les retraits en attente
    getPendingWithdrawals = async (req: Request, res: Response) => {
        try {
            const pendingWithdrawals = await this.affiliateService.getPendingWithdrawals();

            res.json({
                success: true,
                data: pendingWithdrawals
            });
        } catch (error) {
            if (error instanceof AppError) {
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

    // Traiter un retrait
    processWithdrawal = async (req: Request, res: Response) => {
        try {
            const { id } = req.params;
            const { status, notes } = req.body;
            const adminId = req.user?.id; // Optional chaining for req.user
            if (!adminId) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED); // Add error code
            }

            await this.affiliateService.processWithdrawal(id, adminId, status, notes);

            res.json({
                success: true,
                message: 'Withdrawal processed successfully'
            });
        } catch (error) {
            if (error instanceof AppError) {
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
            if (error instanceof AppError) {
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
            if (error instanceof AppError) {
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

    // Obtenir les analytics
    getAnalytics = async (req: Request, res: Response) => {
        try {
            const analytics = await this.affiliateService.getAnalytics();

            res.json({
                success: true,
                data: analytics
            });
        } catch (error) {
            if (error instanceof AppError) {
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

    // Placeholder for getCommissions
    getCommissions = async (req: Request, res: Response) => {
        // TODO: Implement getCommissions logic
        res.status(501).json({
            success: false,
            message: 'getCommissions not implemented yet'
        });
    };
}

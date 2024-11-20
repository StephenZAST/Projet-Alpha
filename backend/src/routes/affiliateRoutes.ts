import express from 'express';
import { AffiliateController } from '../controllers/affiliateController';
import { isAuthenticated, requireAdminRole, auth } from '../middleware/auth';

const router = express.Router();
const affiliateController = new AffiliateController();

/**
 * @swagger
 * /api/affiliate/register:
 *   post:
 *     tags: [Affiliate]
 *     summary: Register a new affiliate
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - fullName
 *               - email
 *               - phone
 *               - paymentInfo
 *             properties:
 *               fullName: { type: string }
 *               email: { type: string, format: email }
 *               phone: { type: string }
 *               paymentInfo:
 *                 type: object
 *                 properties:
 *                   preferredMethod: { type: string, enum: [MOBILE_MONEY, BANK_TRANSFER] }
 *                   mobileMoneyNumber: { type: string }
 *     responses:
 *       201:
 *         description: Affiliate registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Affiliate'
 */
router.post('/register', affiliateController.register);

/**
 * @swagger
 * /api/affiliate/login:
 *   post:
 *     tags: [Affiliate]
 *     summary: Affiliate login
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email: { type: string, format: email }
 *               password: { type: string }
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token: { type: string }
 *                 affiliate: { $ref: '#/components/schemas/Affiliate' }
 */
router.post('/login', affiliateController.login);

// Routes protégées pour les affiliés
router.use(isAuthenticated);

/**
 * @swagger
 * /api/affiliate/profile:
 *   get:
 *     tags: [Affiliate]
 *     summary: Get affiliate profile
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Affiliate profile
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Affiliate'
 */
router.get('/profile', affiliateController.getProfile);

/**
 * @swagger
 * /api/affiliate/profile:
 *   put:
 *     tags: [Affiliate]
 *     summary: Update affiliate profile
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fullName: { type: string }
 *               phone: { type: string }
 *               paymentInfo:
 *                 type: object
 *                 properties:
 *                   preferredMethod: { type: string }
 *                   mobileMoneyNumber: { type: string }
 *     responses:
 *       200:
 *         description: Profile updated successfully
 */
router.put('/profile', affiliateController.updateProfile);

/**
 * @swagger
 * /api/affiliate/stats:
 *   get:
 *     tags: [Affiliate]
 *     summary: Get affiliate statistics
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Affiliate statistics
 */
router.get('/stats', affiliateController.getStats);

/**
 * @swagger
 * /api/affiliate/commissions:
 *   get:
 *     tags: [Affiliate]
 *     summary: Get affiliate commissions
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of commissions
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Commission'
 */
router.get('/commissions', affiliateController.getCommissions);

/**
 * @swagger
 * /api/affiliate/withdrawal/request:
 *   post:
 *     tags: [Affiliate]
 *     summary: Request commission withdrawal
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - amount
 *             properties:
 *               amount: { type: number }
 *     responses:
 *       201:
 *         description: Withdrawal request created successfully
 */
router.post('/withdrawal/request', affiliateController.requestWithdrawal);

/**
 * @swagger
 * /api/affiliate/withdrawals:
 *   get:
 *     tags: [Affiliate]
 *     summary: Get affiliate withdrawal history
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of withdrawals
 */
router.get('/withdrawals', affiliateController.getWithdrawalHistory);

// Routes admin/secrétaire
router.use(auth);

/**
 * @swagger
 * /api/affiliate/pending:
 *   get:
 *     tags: [Admin]
 *     summary: Get pending affiliates
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pending affiliates
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Affiliate'
 */
router.get('/pending', affiliateController.getPendingAffiliates);

/**
 * @swagger
 * /api/affiliate/{id}/approve:
 *   post:
 *     tags: [Admin]
 *     summary: Approve affiliate
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Affiliate approved successfully
 */
router.post('/:id/approve', affiliateController.approveAffiliate);

/**
 * @swagger
 * /api/affiliate/withdrawals/pending:
 *   get:
 *     tags: [Admin]
 *     summary: Get pending withdrawals
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pending withdrawals
 */
router.get('/withdrawals/pending', affiliateController.getPendingWithdrawals);

/**
 * @swagger
 * /api/affiliate/withdrawal/{id}/process:
 *   post:
 *     tags: [Admin]
 *     summary: Process withdrawal
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Withdrawal processed successfully
 */
router.post('/withdrawal/:id/process', affiliateController.processWithdrawal);

// Routes admin uniquement
router.use(requireAdminRole);

/**
 * @swagger
 * /api/affiliate/all:
 *   get:
 *     tags: [Admin]
 *     summary: Get all affiliates
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all affiliates
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Affiliate'
 */
router.get('/all', affiliateController.getAllAffiliates);

/**
 * @swagger
 * /api/affiliate/commission-rules:
 *   post:
 *     tags: [Admin]
 *     summary: Update commission rules
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - rate
 *             properties:
 *               rate: { type: number }
 *     responses:
 *       200:
 *         description: Commission rules updated successfully
 */
router.post('/commission-rules', affiliateController.updateCommissionRules);

/**
 * @swagger
 * /api/affiliate/analytics:
 *   get:
 *     tags: [Admin]
 *     summary: Get affiliate analytics
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Affiliate system analytics
 */
router.get('/analytics', affiliateController.getAnalytics);

export default router;

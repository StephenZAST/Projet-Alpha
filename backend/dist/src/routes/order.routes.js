"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const address_controller_1 = require("../controllers/address.controller");
const index_1 = require("../controllers/order.controller/index");
const flashOrder_controller_1 = require("../controllers/order.controller/flashOrder.controller");
const clientOrder_controller_1 = require("../controllers/order.controller/clientOrder.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validators_1 = require("../middleware/validators");
const flashOrderValidator_1 = require("../middleware/flashOrderValidator");
const asyncHandler_1 = require("../utils/asyncHandler");
const admin_service_1 = require("../services/admin.service");
const router = express_1.default.Router();
// 📱 Routes dédiées au CLIENT APP (avec données enrichies)
// Ces routes sont spécifiques à l'app client et n'affectent pas les autres apps
router.get('/client/my-orders', auth_middleware_1.authenticateToken, (0, asyncHandler_1.asyncHandler)(clientOrder_controller_1.ClientOrderController.getMyOrdersEnriched));
router.get('/client/by-id/:orderId', auth_middleware_1.authenticateToken, (0, asyncHandler_1.asyncHandler)(clientOrder_controller_1.ClientOrderController.getOrderByIdEnriched));
router.get('/client/recent', auth_middleware_1.authenticateToken, (0, asyncHandler_1.asyncHandler)(clientOrder_controller_1.ClientOrderController.getRecentOrdersEnriched));
// Dedicated endpoint for searching by order ID (placed immediately after router declaration)
router.get('/by-id/:orderId', auth_middleware_1.authenticateToken, (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getOrderById));
// Routes pour la carte des commandes
router.get('/map/orders', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN', 'DELIVERY']), (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getOrdersForMap));
router.get('/map/stats', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getOrdersGeoStats));
// Ajouter des logs pour le debugging
router.use((req, res, next) => {
    console.log('Order Route Request:', {
        path: req.path,
        method: req.method,
        headers: req.headers,
        body: req.body,
        user: req.user
    });
    next();
});
// Protection des routes avec authentification
router.use(auth_middleware_1.authenticateToken);
// Route pour modifier l'adresse d'une commande
router.patch('/:orderId/address', auth_middleware_1.authenticateToken, (0, asyncHandler_1.asyncHandler)(address_controller_1.AddressController.updateOrderAddress));
// PATCH flexible d'une commande (paiement, dates, code affilié, etc.)
router.patch('/:orderId', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN', 'CLIENT']), (0, asyncHandler_1.asyncHandler)(index_1.OrderController.patchOrderFields));
// Route principale pour la recherche et la liste des commandes
router.get('/', auth_middleware_1.authenticateToken, (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 50;
        const status = req.query.status ? req.query.status.toUpperCase() : undefined;
        const sortField = req.query.sortField || 'createdAt';
        const sortOrder = req.query.sortOrder || 'desc';
        const startDate = req.query.startDate;
        const endDate = req.query.endDate;
        const paymentMethod = req.query.paymentMethod;
        const serviceTypeId = req.query.serviceTypeId;
        const minAmount = req.query.minAmount;
        const maxAmount = req.query.maxAmount;
        const isFlashOrder = req.query.isFlashOrder !== undefined ? req.query.isFlashOrder === 'true' : undefined;
        const query = req.query.query;
        const affiliateCode = req.query.affiliateCode;
        const recurrenceType = req.query.recurrenceType;
        const city = req.query.city;
        const postalCode = req.query.postalCode;
        const collectionDateStart = req.query.collectionDateStart;
        const collectionDateEnd = req.query.collectionDateEnd;
        const deliveryDateStart = req.query.deliveryDateStart;
        const deliveryDateEnd = req.query.deliveryDateEnd;
        const isRecurring = req.query.isRecurring !== undefined ? req.query.isRecurring === 'true' : undefined;
        const sortByNextRecurrenceDate = req.query.sortByNextRecurrenceDate;
        const result = yield admin_service_1.AdminService.getAllOrders(page, limit, {
            status,
            sortField,
            sortOrder,
            startDate,
            endDate,
            paymentMethod,
            serviceTypeId,
            minAmount,
            maxAmount,
            isFlashOrder,
            query,
            affiliateCode,
            recurrenceType,
            city,
            postalCode,
            collectionDateStart,
            collectionDateEnd,
            deliveryDateStart,
            deliveryDateEnd,
            isRecurring,
            sortByNextRecurrenceDate
        });
        res.json({
            success: true,
            data: result.orders,
            pagination: {
                total: result.total,
                currentPage: page,
                limit,
                totalPages: result.pages
            }
        });
    }
    catch (error) {
        console.error('Error fetching orders:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch orders'
        });
    }
})));
// Routes flash
router.route('/flash')
    .post(auth_middleware_1.authenticateToken, flashOrderValidator_1.validateCreateFlashOrder, (0, asyncHandler_1.asyncHandler)(flashOrder_controller_1.FlashOrderController.createFlashOrder))
    .get(auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)(flashOrder_controller_1.FlashOrderController.getAllPendingOrders));
router.get('/flash/draft', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(flashOrder_controller_1.FlashOrderController.getAllPendingOrders));
// Commande standard
router.post('/', validators_1.validateOrder, (0, asyncHandler_1.asyncHandler)(index_1.OrderController.createOrder));
router.get('/my-orders', (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getUserOrders));
router.get('/by-status', (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getOrdersByStatus));
router.get('/recent', (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getRecentOrders));
router.get('/:orderId', (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getOrderDetails));
router.get('/:orderId/invoice', (0, asyncHandler_1.asyncHandler)(index_1.OrderController.generateInvoice));
router.post('/calculate-total', (0, asyncHandler_1.asyncHandler)(index_1.OrderController.calculateTotal));
// Commandes flash
router.patch('/flash/:orderId/complete', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN', 'DELIVERY']), flashOrderValidator_1.validateCompleteFlashOrder, (0, asyncHandler_1.asyncHandler)(flashOrder_controller_1.FlashOrderController.completeFlashOrder));
router.patch('/:orderId/status', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN', 'DELIVERY']), (0, asyncHandler_1.asyncHandler)(index_1.OrderController.updateOrderStatus));
router.get('/all', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)(index_1.OrderController.getAllOrders));
router.delete('/:orderId', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)(index_1.OrderController.deleteOrder));
exports.default = router;

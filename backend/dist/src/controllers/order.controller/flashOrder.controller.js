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
exports.FlashOrderController = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class FlashOrderController {
    static createFlashOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            console.log('[FlashOrderController] Creating flash order with data:', req.body);
            try {
                const { addressId, notes, note } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId) {
                    console.error('[FlashOrderController] No userId found in request');
                    return res.status(401).json({ error: 'Unauthorized - User ID required' });
                }
                const noteText = notes || note;
                // --- Injection automatique du code affilié si non fourni ---
                let affiliateCodeToUse = req.body.affiliateCode;
                if (!affiliateCodeToUse) {
                    const now = new Date();
                    const link = yield prisma_1.default.affiliate_client_links.findFirst({
                        where: {
                            client_id: userId,
                            start_date: { lte: now },
                            OR: [
                                { end_date: null },
                                { end_date: { gte: now } }
                            ],
                            affiliate: {
                                is_active: true,
                                status: 'ACTIVE'
                            }
                        },
                        include: {
                            affiliate: true
                        },
                        orderBy: { start_date: 'desc' }
                    });
                    if (link && link.affiliate && link.affiliate.affiliate_code) {
                        affiliateCodeToUse = link.affiliate.affiliate_code;
                    }
                }
                // Créer la commande avec les métadonnées et le code affilié injecté
                const defaultServiceTypeId = yield prisma_1.default.service_types.findFirst({
                    where: {
                        is_default: true
                    },
                    select: {
                        id: true
                    }
                });
                if (!defaultServiceTypeId) {
                    throw new Error('No default service type found');
                }
                const order = yield prisma_1.default.orders.create({
                    data: {
                        userId,
                        addressId,
                        status: 'DRAFT',
                        totalAmount: 0,
                        createdAt: new Date(),
                        updatedAt: new Date(),
                        service_type_id: defaultServiceTypeId.id,
                        affiliateCode: affiliateCodeToUse,
                        order_metadata: {
                            create: {
                                is_flash_order: true,
                                metadata: { note: noteText }
                            }
                        }
                    }
                });
                // Création de la note unique (si fournie)
                let noteRecord = null;
                if (noteText && typeof noteText === 'string' && noteText.trim().length > 0) {
                    noteRecord = yield prisma_1.default.order_notes.create({
                        data: {
                            order_id: order.id,
                            note: noteText,
                            created_at: new Date(),
                            updated_at: new Date()
                        }
                    });
                }
                // Retourne la commande + note unique
                res.json({
                    data: Object.assign(Object.assign({}, order), { note: (noteRecord === null || noteRecord === void 0 ? void 0 : noteRecord.note) || null })
                });
            }
            catch (error) {
                console.error('[FlashOrderController] Unexpected error:', error);
                res.status(500).json({
                    error: 'Failed to create flash order',
                    details: process.env.NODE_ENV === 'development' ? error.message : undefined
                });
            }
        });
    }
    static getAllPendingOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma_1.default.orders.findMany({
                    where: {
                        status: 'DRAFT',
                        order_metadata: {
                            is_flash_order: true
                        }
                    },
                    include: {
                        user: {
                            select: {
                                first_name: true,
                                last_name: true,
                                phone: true,
                                email: true
                            }
                        },
                        address: true,
                        order_notes: true
                    },
                    orderBy: {
                        createdAt: 'desc'
                    }
                });
                // Ajoute le champ note à chaque commande (s'il existe, robustesse)
                const ordersWithNote = orders.map(order => {
                    let note = null;
                    if (order.order_notes && Array.isArray(order.order_notes)) {
                        // Cherche la première note non nulle/non vide
                        const found = order.order_notes.find(n => n && typeof n.note === 'string' && n.note.trim().length > 0);
                        note = found ? found.note : null;
                    }
                    return Object.assign(Object.assign({}, order), { note });
                });
                res.json({ data: ordersWithNote });
            }
            catch (error) {
                console.error('[FlashOrderController] Error fetching pending orders:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static completeFlashOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { orderId } = req.params;
                const { serviceId, items, serviceTypeId, collectionDate, deliveryDate, note // Ajout du champ note dans le payload
                 } = req.body;
                // Vérifier que la commande existe et est une commande flash
                const flashOrder = yield prisma_1.default.orders.findFirst({
                    where: {
                        id: orderId,
                        order_metadata: {
                            is_flash_order: true
                        }
                    },
                    include: {
                        order_metadata: true
                    }
                });
                if (!flashOrder) {
                    return res.status(404).json({ error: 'Flash order not found' });
                }
                if (flashOrder.status !== 'DRAFT') {
                    return res.status(400).json({
                        error: `Cannot complete order in status: ${flashOrder.status}. Order must be in DRAFT status.`
                    });
                }
                // Transaction : mise à jour, calcul des prix, création des items, calcul du total
                const updatedOrder = yield prisma_1.default.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    // 1. Mise à jour de la commande
                    yield tx.orders.update({
                        where: { id: orderId },
                        data: {
                            serviceId,
                            service_type_id: serviceTypeId,
                            collectionDate,
                            deliveryDate,
                            status: 'COLLECTING',
                            updatedAt: new Date()
                        }
                    });
                    // 1bis. Mise à jour ou création de la note si fournie
                    if (typeof note === 'string' && note.trim().length > 0) {
                        const existingNote = yield tx.order_notes.findFirst({
                            where: { order_id: orderId }
                        });
                        if (existingNote) {
                            yield tx.order_notes.update({
                                where: { id: existingNote.id },
                                data: { note, updated_at: new Date() }
                            });
                        }
                        else {
                            yield tx.order_notes.create({
                                data: {
                                    order_id: orderId,
                                    note,
                                    created_at: new Date(),
                                    updated_at: new Date()
                                }
                            });
                        }
                    }
                    // 2. Calcul automatique du unitPrice et création des items
                    let mappedItems = [];
                    if ((items === null || items === void 0 ? void 0 : items.length) > 0) {
                        // Récupérer tous les couples de prix pour les articles concernés
                        const couplePrices = yield tx.article_service_prices.findMany({
                            where: {
                                article_id: { in: items.map((item) => item.articleId) },
                                service_type_id: serviceTypeId,
                                service_id: serviceId
                            }
                        });
                        const couplePriceMap = new Map(couplePrices
                            .filter((c) => c.article_id)
                            .map((c) => [c.article_id, { base_price: Number(c.base_price), premium_price: Number(c.premium_price) }]));
                        mappedItems = items.map((item) => {
                            const couple = couplePriceMap.get(item.articleId);
                            const unitPrice = couple
                                ? (item.isPremium ? couple.premium_price : couple.base_price)
                                : 1; // fallback si pas trouvé
                            return {
                                orderId,
                                articleId: item.articleId,
                                serviceId,
                                quantity: item.quantity,
                                unitPrice,
                                isPremium: item.isPremium,
                                createdAt: new Date(),
                                updatedAt: new Date()
                            };
                        });
                        yield tx.order_items.createMany({ data: mappedItems });
                    }
                    // 3. Calcul du total à partir des items insérés
                    const total = mappedItems.reduce((sum, item) => sum + (item.quantity * item.unitPrice), 0);
                    // 4. Mise à jour du total et retour de la commande complète
                    // Mise à jour du total
                    yield tx.orders.update({
                        where: { id: orderId },
                        data: { totalAmount: total }
                    });
                    // Récupérer la commande et la note unique
                    const order = yield tx.orders.findUnique({
                        where: { id: orderId },
                        include: {
                            user: {
                                select: {
                                    first_name: true,
                                    last_name: true,
                                    phone: true,
                                    email: true
                                }
                            },
                            address: true,
                            order_items: {
                                include: {
                                    article: true
                                }
                            },
                            order_metadata: true
                        }
                    });
                    const noteRecord = yield tx.order_notes.findFirst({ where: { order_id: orderId } });
                    return Object.assign(Object.assign({}, order), { note: (noteRecord === null || noteRecord === void 0 ? void 0 : noteRecord.note) || null });
                }));
                res.json({
                    data: updatedOrder,
                    total: updatedOrder.totalAmount,
                    note: updatedOrder.note,
                    message: 'Flash order completed successfully'
                });
            }
            catch (error) {
                console.error('[FlashOrderController] Error completing flash order:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.FlashOrderController = FlashOrderController;

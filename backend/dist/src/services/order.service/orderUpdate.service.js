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
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrderUpdateService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class OrderUpdateService {
    /**
     * Met à jour un ou plusieurs champs d'une commande (paiement, dates, code affilié, etc.)
     * @param orderId string
     * @param updateFields Partial<{ paymentMethod, collectionDate, deliveryDate, affiliateCode }>
     * @param userId string
     * @param userRole string
     */
    static patchOrderFields(orderId_1) {
        return __awaiter(this, arguments, void 0, function* (orderId, updateFields = {}, userId, userRole) {
            console.log(`[OrderUpdateService] patchOrderFields for order ${orderId} by user ${userId} (${userRole})`, updateFields);
            const allowedRoles = ['ADMIN', 'SUPER_ADMIN'];
            let order;
            try {
                order = yield prisma.orders.findUnique({ where: { id: orderId } });
            }
            catch (err) {
                console.error(`[OrderUpdateService] Error fetching order ${orderId}:`, err);
                throw new Error('Database error while fetching order');
            }
            if (!order) {
                console.warn(`[OrderUpdateService] Order not found: ${orderId}`);
                throw new Error('Order not found');
            }
            if (order.userId !== userId && !allowedRoles.includes(userRole)) {
                console.warn(`[OrderUpdateService] Unauthorized update attempt by user ${userId} (${userRole}) on order ${orderId}`);
                throw new Error('Unauthorized to update order');
            }
            const data = {};
            if (updateFields.paymentMethod)
                data.paymentMethod = updateFields.paymentMethod;
            if (updateFields.collectionDate)
                data.collectionDate = new Date(updateFields.collectionDate);
            if (updateFields.deliveryDate)
                data.deliveryDate = new Date(updateFields.deliveryDate);
            if (updateFields.affiliateCode !== undefined) {
                if (updateFields.affiliateCode) {
                    const affiliate = yield prisma.affiliate_profiles.findFirst({
                        where: {
                            affiliate_code: updateFields.affiliateCode,
                            is_active: true,
                            status: 'ACTIVE'
                        }
                    });
                    if (!affiliate) {
                        throw new Error("Le code affilié fourni n'est pas valide ou n'existe pas.");
                    }
                    data.affiliateCode = updateFields.affiliateCode;
                }
                else {
                    data.affiliateCode = null;
                }
            }
            if (updateFields.status)
                data.status = updateFields.status;
            if (updateFields.service_type_id)
                data.service_type_id = updateFields.service_type_id;
            data.updatedAt = new Date();
            // PATCH ORDER ITEMS LOGIC
            let newServiceTypeId = updateFields.service_type_id || order.service_type_id;
            if (updateFields.items) {
                yield prisma.order_items.deleteMany({ where: { orderId } });
                if (Array.isArray(updateFields.items) && updateFields.items.length > 0) {
                    const PricingService = require('../../services/pricing.service').PricingService;
                    let recalculatedItems = [];
                    for (const item of updateFields.items) {
                        let priceDetails;
                        try {
                            priceDetails = yield PricingService.calculatePrice({
                                articleId: item.articleId,
                                serviceTypeId: newServiceTypeId,
                                quantity: item.quantity,
                                weight: item.weight,
                                isPremium: item.isPremium || false
                            });
                        }
                        catch (err) {
                            let msg = 'Erreur inconnue';
                            if (err instanceof Error) {
                                msg = err.message;
                            }
                            throw new Error(`Erreur de calcul du prix pour l'article ${item.articleId}: ${msg}`);
                        }
                        recalculatedItems.push({
                            orderId: orderId,
                            articleId: item.articleId,
                            serviceId: item.serviceId || null,
                            quantity: item.quantity,
                            unitPrice: priceDetails.unitPrice,
                            isPremium: item.isPremium || false,
                            weight: item.weight !== undefined ? item.weight : null,
                            createdAt: item.createdAt ? new Date(item.createdAt) : new Date(),
                            updatedAt: new Date()
                        });
                    }
                    // Filtrage strict des propriétés autorisées (inclut weight)
                    const filteredItems = recalculatedItems.map(item => ({
                        orderId: item.orderId,
                        articleId: item.articleId,
                        serviceId: item.serviceId,
                        quantity: item.quantity,
                        unitPrice: item.unitPrice,
                        isPremium: item.isPremium,
                        weight: item.weight,
                        createdAt: item.createdAt,
                        updatedAt: item.updatedAt
                    }));
                    // Log pour traquer la présence de propriétés inattendues
                    console.log('[OrderUpdateService] Items à insérer dans order_items:', JSON.stringify(filteredItems, null, 2));
                    yield prisma.order_items.createMany({ data: filteredItems });
                }
            }
            // PATCH ORDER NOTES LOGIC
            if (updateFields.note !== undefined) {
                const existingNote = yield prisma.order_notes.findFirst({
                    where: { order_id: orderId }
                });
                if (updateFields.note && updateFields.note.trim().length > 0) {
                    // Créer ou mettre à jour la note
                    if (existingNote) {
                        yield prisma.order_notes.update({
                            where: { id: existingNote.id },
                            data: {
                                note: updateFields.note,
                                updated_at: new Date()
                            }
                        });
                    }
                    else {
                        yield prisma.order_notes.create({
                            data: {
                                order_id: orderId,
                                note: updateFields.note,
                                created_at: new Date(),
                                updated_at: new Date()
                            }
                        });
                    }
                }
                else {
                    // Supprimer la note si elle existe et que la nouvelle valeur est vide
                    if (existingNote) {
                        yield prisma.order_notes.delete({
                            where: { id: existingNote.id }
                        });
                    }
                }
            }
            // Mise à jour de la commande si des champs ont changé (hors updatedAt)
            const dataKeys = Object.keys(data);
            if (dataKeys.length > 0 && !(dataKeys.length === 1 && dataKeys[0] === 'updatedAt')) {
                let updatedOrder;
                try {
                    updatedOrder = yield prisma.orders.update({
                        where: { id: orderId },
                        data: data
                    });
                }
                catch (err) {
                    console.error(`[OrderUpdateService] Error updating order ${orderId}:`, err);
                    throw new Error('Database error while updating order');
                }
                console.log(`[OrderUpdateService] Order updated successfully:`, updatedOrder);
            }
            // Return the updated order with items
            const orderWithItems = yield prisma.orders.findUnique({
                where: { id: orderId },
                include: {
                    order_items: true,
                    order_notes: {
                        select: {
                            id: true,
                            note: true,
                            created_at: true,
                            updated_at: true
                        }
                    }
                }
            });
            return orderWithItems;
        });
    }
}
exports.OrderUpdateService = OrderUpdateService;

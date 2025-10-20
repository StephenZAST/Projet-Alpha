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
exports.AdminAffiliateLinkController = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class AdminAffiliateLinkController {
    /// Récupérer toutes les liaisons affilié-client
    static getAllLinks(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { page = 1, limit = 10, affiliateId, clientId, isActive } = req.query;
                const skip = (Number(page) - 1) * Number(limit);
                const where = {};
                if (affiliateId)
                    where.affiliate_id = affiliateId;
                if (clientId)
                    where.client_id = clientId;
                // Filtrer par statut actif/inactif
                if (isActive !== undefined) {
                    const now = new Date();
                    if (isActive === 'true') {
                        where.start_date = { lte: now };
                        where.OR = [
                            { end_date: null },
                            { end_date: { gte: now } }
                        ];
                    }
                    else {
                        where.end_date = { lt: now };
                    }
                }
                const [links, total] = yield Promise.all([
                    prisma.affiliate_client_links.findMany({
                        skip,
                        take: Number(limit),
                        where,
                        include: {
                            affiliate: {
                                include: {
                                    users: {
                                        select: {
                                            id: true,
                                            first_name: true,
                                            last_name: true,
                                            email: true
                                        }
                                    }
                                }
                            },
                            client: {
                                select: {
                                    id: true,
                                    first_name: true,
                                    last_name: true,
                                    email: true
                                }
                            }
                        },
                        orderBy: { created_at: 'desc' }
                    }),
                    prisma.affiliate_client_links.count({ where })
                ]);
                const formattedLinks = links.map(link => {
                    var _a;
                    return ({
                        id: link.id,
                        affiliateId: link.affiliate_id,
                        clientId: link.client_id,
                        startDate: link.start_date,
                        endDate: link.end_date,
                        isActive: !link.end_date || link.end_date >= new Date(),
                        createdAt: link.created_at,
                        updatedAt: link.updated_at,
                        affiliateName: ((_a = link.affiliate) === null || _a === void 0 ? void 0 : _a.users)
                            ? `${link.affiliate.users.first_name} ${link.affiliate.users.last_name}`
                            : 'Affilié inconnu',
                        clientName: link.client
                            ? `${link.client.first_name} ${link.client.last_name}`
                            : 'Client inconnu',
                        affiliate: link.affiliate ? {
                            id: link.affiliate.id,
                            affiliateCode: link.affiliate.affiliate_code,
                            user: link.affiliate.users ? {
                                id: link.affiliate.users.id,
                                firstName: link.affiliate.users.first_name,
                                lastName: link.affiliate.users.last_name,
                                email: link.affiliate.users.email
                            } : null
                        } : null,
                        client: link.client ? {
                            id: link.client.id,
                            firstName: link.client.first_name,
                            lastName: link.client.last_name,
                            email: link.client.email
                        } : null
                    });
                });
                res.json({
                    success: true,
                    data: formattedLinks,
                    pagination: {
                        total,
                        page: Number(page),
                        limit: Number(limit),
                        totalPages: Math.ceil(total / Number(limit))
                    }
                });
            }
            catch (error) {
                console.error('[AdminAffiliateLinkController] Get all links error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    /// Créer une nouvelle liaison affilié-client
    static createLink(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c;
            try {
                const { affiliateId, clientId, startDate, endDate } = req.body;
                // Validation des champs requis
                if (!affiliateId || !clientId || !startDate) {
                    return res.status(400).json({
                        error: 'Missing required fields',
                        required: ['affiliateId', 'clientId', 'startDate']
                    });
                }
                // Vérifier que l'affilié existe et est actif
                const affiliate = yield prisma.affiliate_profiles.findUnique({
                    where: { id: affiliateId },
                    include: {
                        users: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true
                            }
                        }
                    }
                });
                if (!affiliate) {
                    return res.status(404).json({ error: 'Affiliate not found' });
                }
                if (!affiliate.is_active) {
                    return res.status(400).json({ error: 'Affiliate is not active' });
                }
                // Vérifier que le client existe
                const client = yield prisma.users.findUnique({
                    where: { id: clientId },
                    select: {
                        id: true,
                        first_name: true,
                        last_name: true,
                        email: true,
                        role: true
                    }
                });
                if (!client) {
                    return res.status(404).json({ error: 'Client not found' });
                }
                if (client.role !== 'CLIENT') {
                    return res.status(400).json({ error: 'User is not a client' });
                }
                // Vérifier qu'il n'y a pas déjà une liaison active
                const existingLink = yield prisma.affiliate_client_links.findFirst({
                    where: {
                        affiliate_id: affiliateId,
                        client_id: clientId,
                        start_date: { lte: new Date(startDate) },
                        OR: [
                            { end_date: null },
                            { end_date: { gte: new Date(startDate) } }
                        ]
                    }
                });
                if (existingLink) {
                    return res.status(409).json({
                        error: 'An active link already exists between this affiliate and client'
                    });
                }
                // Créer la liaison
                const link = yield prisma.affiliate_client_links.create({
                    data: {
                        affiliate_id: affiliateId,
                        client_id: clientId,
                        start_date: new Date(startDate),
                        end_date: endDate ? new Date(endDate) : null,
                        created_by: (_a = req.user) === null || _a === void 0 ? void 0 : _a.id
                    }
                });
                const formattedLink = {
                    id: link.id,
                    affiliateId: link.affiliate_id,
                    clientId: link.client_id,
                    startDate: link.start_date,
                    endDate: link.end_date,
                    isActive: !link.end_date || link.end_date >= new Date(),
                    createdAt: link.created_at,
                    updatedAt: link.updated_at,
                    affiliateName: `${(_b = affiliate.users) === null || _b === void 0 ? void 0 : _b.first_name} ${(_c = affiliate.users) === null || _c === void 0 ? void 0 : _c.last_name}`,
                    clientName: `${client.first_name} ${client.last_name}`,
                    affiliate: {
                        id: affiliate.id,
                        affiliateCode: affiliate.affiliate_code,
                        user: affiliate.users
                    },
                    client: client
                };
                res.status(201).json({
                    success: true,
                    data: formattedLink
                });
            }
            catch (error) {
                console.error('[AdminAffiliateLinkController] Create link error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    /// Mettre à jour une liaison affilié-client
    static updateLink(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { linkId } = req.params;
                const { affiliateId, clientId, startDate, endDate, isActive } = req.body;
                // Vérifier que la liaison existe
                const existingLink = yield prisma.affiliate_client_links.findUnique({
                    where: { id: linkId }
                });
                if (!existingLink) {
                    return res.status(404).json({ error: 'Link not found' });
                }
                const updateData = {};
                if (affiliateId && affiliateId !== existingLink.affiliate_id) {
                    // Vérifier que le nouvel affilié existe
                    const affiliate = yield prisma.affiliate_profiles.findUnique({
                        where: { id: affiliateId }
                    });
                    if (!affiliate) {
                        return res.status(404).json({ error: 'New affiliate not found' });
                    }
                    updateData.affiliate_id = affiliateId;
                }
                if (clientId && clientId !== existingLink.client_id) {
                    // Vérifier que le nouveau client existe
                    const client = yield prisma.users.findUnique({
                        where: { id: clientId }
                    });
                    if (!client) {
                        return res.status(404).json({ error: 'New client not found' });
                    }
                    updateData.client_id = clientId;
                }
                if (startDate)
                    updateData.start_date = new Date(startDate);
                if (endDate !== undefined) {
                    updateData.end_date = endDate ? new Date(endDate) : null;
                }
                // Si isActive est false, définir end_date à maintenant
                if (isActive === false) {
                    updateData.end_date = new Date();
                }
                const updatedLink = yield prisma.affiliate_client_links.update({
                    where: { id: linkId },
                    data: updateData,
                    include: {
                        affiliate: {
                            include: {
                                users: {
                                    select: {
                                        id: true,
                                        first_name: true,
                                        last_name: true,
                                        email: true
                                    }
                                }
                            }
                        },
                        client: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true
                            }
                        }
                    }
                });
                const formattedLink = {
                    id: updatedLink.id,
                    affiliateId: updatedLink.affiliate_id,
                    clientId: updatedLink.client_id,
                    startDate: updatedLink.start_date,
                    endDate: updatedLink.end_date,
                    isActive: !updatedLink.end_date || updatedLink.end_date >= new Date(),
                    createdAt: updatedLink.created_at,
                    updatedAt: updatedLink.updated_at,
                    affiliateName: ((_a = updatedLink.affiliate) === null || _a === void 0 ? void 0 : _a.users)
                        ? `${updatedLink.affiliate.users.first_name} ${updatedLink.affiliate.users.last_name}`
                        : 'Affilié inconnu',
                    clientName: updatedLink.client
                        ? `${updatedLink.client.first_name} ${updatedLink.client.last_name}`
                        : 'Client inconnu',
                    affiliate: updatedLink.affiliate ? {
                        id: updatedLink.affiliate.id,
                        affiliateCode: updatedLink.affiliate.affiliate_code,
                        user: updatedLink.affiliate.users
                    } : null,
                    client: updatedLink.client
                };
                res.json({
                    success: true,
                    data: formattedLink
                });
            }
            catch (error) {
                console.error('[AdminAffiliateLinkController] Update link error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    /// Supprimer une liaison affilié-client
    static deleteLink(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { linkId } = req.params;
                // Vérifier que la liaison existe
                const existingLink = yield prisma.affiliate_client_links.findUnique({
                    where: { id: linkId }
                });
                if (!existingLink) {
                    return res.status(404).json({ error: 'Link not found' });
                }
                yield prisma.affiliate_client_links.delete({
                    where: { id: linkId }
                });
                res.json({
                    success: true,
                    message: 'Link deleted successfully'
                });
            }
            catch (error) {
                console.error('[AdminAffiliateLinkController] Delete link error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    /// Obtenir les statistiques des liaisons
    static getLinkStats(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const now = new Date();
                const [totalLinks, activeLinks, inactiveLinks, linksThisMonth] = yield Promise.all([
                    prisma.affiliate_client_links.count(),
                    prisma.affiliate_client_links.count({
                        where: {
                            start_date: { lte: now },
                            OR: [
                                { end_date: null },
                                { end_date: { gte: now } }
                            ]
                        }
                    }),
                    prisma.affiliate_client_links.count({
                        where: {
                            end_date: { lt: now }
                        }
                    }),
                    prisma.affiliate_client_links.count({
                        where: {
                            created_at: {
                                gte: new Date(now.getFullYear(), now.getMonth(), 1)
                            }
                        }
                    })
                ]);
                res.json({
                    success: true,
                    data: {
                        totalLinks,
                        activeLinks,
                        inactiveLinks,
                        linksThisMonth
                    }
                });
            }
            catch (error) {
                console.error('[AdminAffiliateLinkController] Get link stats error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.AdminAffiliateLinkController = AdminAffiliateLinkController;

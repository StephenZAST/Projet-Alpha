import { Router } from 'express';
import { authenticateToken } from '../middleware/auth.middleware';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Middleware pour vérifier les droits admin
const adminCheck = (req: any, res: any, next: any) => {
  if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

// GET /admin/affiliate-links - Récupérer toutes les liaisons
router.get('/', authenticateToken, adminCheck, async (req, res) => {
  try {
    const { page = 1, limit = 10, affiliateId, clientId, isActive } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const where: any = {};
    if (affiliateId) where.affiliate_id = affiliateId;
    if (clientId) where.client_id = clientId;
    if (isActive !== undefined) {
      // Logique pour déterminer si actif basé sur les dates
      const now = new Date();
      if (isActive === 'true') {
        where.start_date = { lte: now };
        where.OR = [
          { end_date: null },
          { end_date: { gte: now } }
        ];
      }
    }

    const [links, total] = await Promise.all([
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

    const formattedLinks = links.map(link => ({
      id: link.id,
      affiliateId: link.affiliate_id,
      clientId: link.client_id,
      startDate: link.start_date,
      endDate: link.end_date,
      isActive: !link.end_date || link.end_date >= new Date(),
      createdAt: link.created_at,
      updatedAt: link.updated_at,
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
    }));

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
  } catch (error: any) {
    console.error('[AdminAffiliateLink] Get links error:', error);
    res.status(500).json({ error: error.message });
  }
});

// POST /admin/affiliate-links - Créer une nouvelle liaison
router.post('/', authenticateToken, adminCheck, async (req, res) => {
  try {
    const { affiliateId, clientId, startDate, endDate } = req.body;

    if (!affiliateId || !clientId || !startDate) {
      return res.status(400).json({
        error: 'Missing required fields',
        required: ['affiliateId', 'clientId', 'startDate']
      });
    }

    // Vérifier que l'affilié existe
    const affiliate = await prisma.affiliate_profiles.findUnique({
      where: { id: affiliateId }
    });
    if (!affiliate) {
      return res.status(404).json({ error: 'Affiliate not found' });
    }

    // Vérifier que le client existe
    const client = await prisma.users.findUnique({
      where: { id: clientId }
    });
    if (!client) {
      return res.status(404).json({ error: 'Client not found' });
    }

    // Créer la liaison
    const link = await prisma.affiliate_client_links.create({
      data: {
        affiliate_id: affiliateId,
        client_id: clientId,
        start_date: new Date(startDate),
        end_date: endDate ? new Date(endDate) : null,
        created_by: req.user?.id
      },
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
      id: link.id,
      affiliateId: link.affiliate_id,
      clientId: link.client_id,
      startDate: link.start_date,
      endDate: link.end_date,
      isActive: !link.end_date || link.end_date >= new Date(),
      createdAt: link.created_at,
      updatedAt: link.updated_at,
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
    };

    res.status(201).json({
      success: true,
      data: formattedLink
    });
  } catch (error: any) {
    console.error('[AdminAffiliateLink] Create link error:', error);
    res.status(500).json({ error: error.message });
  }
});

// PUT /admin/affiliate-links/:linkId - Mettre à jour une liaison
router.put('/:linkId', authenticateToken, adminCheck, async (req, res) => {
  try {
    const { linkId } = req.params;
    const { affiliateId, clientId, startDate, endDate, isActive } = req.body;

    const updateData: any = {};
    if (affiliateId) updateData.affiliate_id = affiliateId;
    if (clientId) updateData.client_id = clientId;
    if (startDate) updateData.start_date = new Date(startDate);
    if (endDate !== undefined) {
      updateData.end_date = endDate ? new Date(endDate) : null;
    }
    if (isActive !== undefined && !isActive) {
      updateData.end_date = new Date(); // Désactiver en mettant end_date à maintenant
    }

    const link = await prisma.affiliate_client_links.update({
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
      id: link.id,
      affiliateId: link.affiliate_id,
      clientId: link.client_id,
      startDate: link.start_date,
      endDate: link.end_date,
      isActive: !link.end_date || link.end_date >= new Date(),
      createdAt: link.created_at,
      updatedAt: link.updated_at,
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
    };

    res.json({
      success: true,
      data: formattedLink
    });
  } catch (error: any) {
    console.error('[AdminAffiliateLink] Update link error:', error);
    res.status(500).json({ error: error.message });
  }
});

// DELETE /admin/affiliate-links/:linkId - Supprimer une liaison
router.delete('/:linkId', authenticateToken, adminCheck, async (req, res) => {
  try {
    const { linkId } = req.params;

    await prisma.affiliate_client_links.delete({
      where: { id: linkId }
    });

    res.json({
      success: true,
      message: 'Link deleted successfully'
    });
  } catch (error: any) {
    console.error('[AdminAffiliateLink] Delete link error:', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;
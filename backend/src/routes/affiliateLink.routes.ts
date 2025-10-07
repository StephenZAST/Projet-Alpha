import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Routes pour les liens d'affiliation côté affilié
router.get('/linked-clients', authMiddleware, async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    console.log('[AffiliateLink] Getting linked clients for user:', userId);

    // Récupérer le profil affilié de l'utilisateur
    const affiliateProfile = await prisma.affiliate_profiles.findUnique({
      where: { userId: userId }
    });

    if (!affiliateProfile) {
      return res.status(404).json({ 
        error: 'Affiliate profile not found',
        message: 'User is not an affiliate'
      });
    }

    console.log('[AffiliateLink] Found affiliate profile:', affiliateProfile.id);

    // APPROCHE HYBRIDE : Récupérer les clients de deux sources
    
    // 1. Liaisons administratives directes (affiliate_client_links)
    const now = new Date();
    const adminLinks = await prisma.affiliate_client_links.findMany({
      where: {
        affiliate_id: affiliateProfile.id,
        start_date: { lte: now },
        OR: [
          { end_date: null },
          { end_date: { gte: now } }
        ]
      },
      include: {
        client: {
          select: {
            id: true,
            first_name: true,
            last_name: true,
            email: true,
            phone: true
          }
        }
      }
    });

    // 2. Clients qui ont utilisé le code affilié (commandes avec affiliateCode)
    const clientsWithOrders = await prisma.orders.findMany({
      where: {
        affiliateCode: affiliateProfile.affiliate_code,
        NOT: {
          userId: {
            in: adminLinks.map(link => link.client_id) // Éviter les doublons
          }
        }
      },
      select: {
        userId: true,
        user: {
          select: {
            id: true,
            first_name: true,
            last_name: true,
            email: true,
            phone: true
          }
        },
        createdAt: true
      },
      distinct: ['userId'],
      orderBy: { createdAt: 'asc' }
    });

    console.log('[AffiliateLink] Found', adminLinks.length, 'admin links and', clientsWithOrders.length, 'organic clients');

    // Combiner les deux sources
    const allLinkedClients = [];

    // Traiter les liaisons administratives
    for (const link of adminLinks) {
      const client = link.client;
      
      // Statistiques depuis la date de liaison
      const ordersCount = await prisma.orders.count({
        where: {
          userId: client.id,
          createdAt: { gte: link.start_date }
        }
      });

      // Calculer les commissions gagnées par l'affilié pour ce client
      const commissionsSum = await prisma.commission_transactions.aggregate({
        where: {
          affiliate_id: affiliateProfile.id,
          orders: {
            userId: client.id,
            createdAt: { gte: link.start_date },
            status: { in: ['DELIVERED'] }
          }
        },
        _sum: { amount: true }
      });

      const totalCommissions = Number(commissionsSum._sum?.amount || 0);

      allLinkedClients.push({
        client: {
          id: client.id,
          firstName: client.first_name,
          lastName: client.last_name,
          email: client.email,
          phone: client.phone,
          initials: `${client.first_name.charAt(0)}${client.last_name.charAt(0)}`.toUpperCase(),
          displayName: `${client.first_name} ${client.last_name}`
        },
        link: {
          id: link.id,
          startDate: link.start_date,
          endDate: link.end_date,
          isActive: !link.end_date || link.end_date >= now,
          type: 'ADMIN_LINK' // Type de liaison
        },
        ordersCount,
        totalCommissions // 💰 Commissions gagnées au lieu du total dépensé
      });
    }

    // Traiter les clients organiques (via code affilié)
    for (const orderData of clientsWithOrders) {
      const client = orderData.user;
      
      // Statistiques depuis la première commande
      const ordersCount = await prisma.orders.count({
        where: {
          userId: client.id,
          affiliateCode: affiliateProfile.affiliate_code
        }
      });

      // Calculer les commissions gagnées par l'affilié pour ce client organique
      const commissionsSum = await prisma.commission_transactions.aggregate({
        where: {
          affiliate_id: affiliateProfile.id,
          orders: {
            userId: client.id,
            affiliateCode: affiliateProfile.affiliate_code,
            status: { in: ['DELIVERED'] }
          }
        },
        _sum: { amount: true }
      });

      const totalCommissions = Number(commissionsSum._sum?.amount || 0);

      allLinkedClients.push({
        client: {
          id: client.id,
          firstName: client.first_name,
          lastName: client.last_name,
          email: client.email,
          phone: client.phone,
          initials: `${client.first_name.charAt(0)}${client.last_name.charAt(0)}`.toUpperCase(),
          displayName: `${client.first_name} ${client.last_name}`
        },
        link: {
          id: `organic_${client.id}`, // ID synthétique
          startDate: orderData.createdAt,
          endDate: null,
          isActive: true,
          type: 'ORGANIC_CLIENT' // Type de liaison
        },
        ordersCount,
        totalCommissions // 💰 Commissions gagnées au lieu du total dépensé
      });
    }

    // Trier par date de liaison (plus récent en premier)
    allLinkedClients.sort((a, b) => {
      const dateA = a.link.startDate ? new Date(a.link.startDate).getTime() : 0;
      const dateB = b.link.startDate ? new Date(b.link.startDate).getTime() : 0;
      return dateB - dateA;
    });

    console.log('[AffiliateLink] Returning', allLinkedClients.length, 'total linked clients');

    res.json({
      success: true,
      data: allLinkedClients,
      meta: {
        adminLinks: adminLinks.length,
        organicClients: clientsWithOrders.length,
        total: allLinkedClients.length
      }
    });
  } catch (error: any) {
    console.error('[AffiliateLink] Get linked clients error:', error);
    res.status(500).json({ 
      error: error.message,
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});

export default router;
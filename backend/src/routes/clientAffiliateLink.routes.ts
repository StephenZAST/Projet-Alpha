import { Router } from 'express';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

// Routes pour les clients concernant leurs liens d'affiliation
router.get('/my-affiliate-links', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // TODO: Implémenter la logique pour récupérer les liens d'affiliation du client
    res.json({
      success: true,
      data: []
    });
  } catch (error: any) {
    console.error('[ClientAffiliateLink] Get my links error:', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;
const express = require('express');
const admin = require('firebase-admin');
const { ZoneService } = require('../../src/services/zones');
const { AppError } = require('../../src/utils/errors');
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');

const router = express.Router();
const zoneService = new ZoneService();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// GET /zones
router.get('/', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const zones = await zoneService.getZones();
    res.json(zones);
  } catch (error) {
    console.error('Error fetching zones:', error);
    res.status(500).json({ error: 'Failed to fetch zones' });
  }
});

// GET /zones/:id
router.get('/:id', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const zoneId = req.params.id;
    const zone = await zoneService.getZoneById(zoneId);
    if (!zone) {
      return res.status(404).json({ error: 'Zone not found' });
    }
    res.json(zone);
  } catch (error) {
    console.error('Error fetching zone:', error);
    res.status(500).json({ error: 'Failed to fetch zone' });
  }
});

// POST /zones
router.post('/', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const zone = await zoneService.createZone(req.body);
    res.status(201).json(zone);
  } catch (error) {
    console.error('Error creating zone:', error);
    res.status(500).json({ error: 'Failed to create zone' });
  }
});

// PUT /zones/:id
router.put('/:id', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const zoneId = req.params.id;
    const updatedZone = await zoneService.updateZone(zoneId, req.body);
    if (!updatedZone) {
      return res.status(404).json({ error: 'Zone not found' });
    }
    res.json(updatedZone);
  } catch (error) {
    console.error('Error updating zone:', error);
    res.status(500).json({ error: 'Failed to update zone' });
  }
});

// DELETE /zones/:id
router.delete('/:id', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const zoneId = req.params.id;
    await zoneService.deleteZone(zoneId);
    res.status(204).send(); // No content
  } catch (error) {
    console.error('Error deleting zone:', error);
    res.status(500).json({ error: 'Failed to delete zone' });
  }
});

module.exports = router;

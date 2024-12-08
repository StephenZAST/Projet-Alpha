const express = require('express');
const admin = require('firebase-admin');
const { requireAdminRolePath } = require('../middleware/auth');
const { UserRole } = require('../models/user');

const db = admin.firestore();
const router = express.Router();

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

// Apply middleware to all routes
router.use(isAuthenticated);
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

// GET /adminLogs - Get all admin logs
router.get('/', async (req, res) => {
  try {
    const logsSnapshot = await db.collection('admin_logs').orderBy('createdAt', 'desc').limit(100).get();
    const logs = logsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(logs);
  } catch (error) {
    console.error('Error getting admin logs:', error);
    res.status(500).json({ error: 'Failed to retrieve admin logs' });
  }
});

// GET /adminLogs/:id - Get admin log by ID
router.get('/:id', async (req, res) => {
  try {
    const logDoc = await db.collection('admin_logs').doc(req.params.id).get();

    if (!logDoc.exists) {
      return res.status(404).json({ error: 'Log not found' });
    }

    res.json({ id: logDoc.id, ...logDoc.data() });
  } catch (error) {
    console.error('Error getting admin log:', error);
    res.status(500).json({ error: 'Failed to retrieve admin log' });
  }
});

// POST /adminLogs - Create a new admin log
router.post('/', async (req, res) => {
  try {
    const { action, details } = req.body;
    const user = req.user;

    const logRef = db.collection('admin_logs').doc();
    const now = new Date();

    await logRef.set({
      id: logRef.id,
      adminId: user.uid, // Use user.uid instead of user.id
      adminName: `${user.firstName} ${user.lastName}`,
      action,
      details,
      createdAt: now,
      updatedAt: now,
    });

    res.status(201).json({
      id: logRef.id,
      message: 'Admin log created successfully',
    });
  } catch (error) {
    console.error('Error creating admin log:', error);
    res.status(500).json({ error: 'Failed to create admin log' });
  }
});

// PUT /adminLogs/:id - Update an existing admin log
router.put('/:id', async (req, res) => {
  try {
    const { action, details } = req.body;
    const logRef = db.collection('admin_logs').doc(req.params.id);

    const logDoc = await logRef.get();
    if (!logDoc.exists) {
      return res.status(404).json({ error: 'Log not found' });
    }

    await logRef.update({
      action,
      details,
      updatedAt: new Date(),
    });

    res.json({
      id: logRef.id,
      message: 'Admin log updated successfully',
    });
  } catch (error) {
    console.error('Error updating admin log:', error);
    res.status(500).json({ error: 'Failed to update admin log' });
  }
});

// DELETE /adminLogs/:id - Delete an admin log
router.delete('/:id', async (req, res) => {
  try {
    const logRef = db.collection('admin_logs').doc(req.params.id);

    const logDoc = await logRef.get();
    if (!logDoc.exists) {
      return res.status(404).json({ error: 'Log not found' });
    }

    await logRef.delete();

    res.json({
      message: 'Admin log deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting admin log:', error);
    res.status(500).json({ error: 'Failed to delete admin log' });
  }
});

module.exports = router;

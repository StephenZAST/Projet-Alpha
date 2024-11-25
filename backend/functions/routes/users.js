const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();
const router = express.Router();

// /users
router.get('/', async (req, res) => { // Renamed function to getUsers
  try {
    const usersSnapshot = await db.collection('users').get();
    const users = usersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

module.exports = router;

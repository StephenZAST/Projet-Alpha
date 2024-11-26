const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();
const auth = admin.auth();
const router = express.Router();

// /auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const userRecord = await auth.signInWithEmailAndPassword(email, password);
    const token = await userRecord.user.getIdToken();

    res.status(200).json({ token });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Failed to log in' });
  }
});

// /auth/register
router.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const userRecord = await auth.createUser({ email, password });
    const token = await userRecord.uid; // Use uid as token for now

    res.status(201).json({ token });
  } catch (error) {
    console.error('Error during registration:', error);
    res.status(500).json({ error: 'Failed to register' });
  }
});

// /auth/me
router.get('/me', async (req, res) => {
  try {
    // Get the ID token from the Authorization header
    const idToken = req.headers.authorization?.split('Bearer ')[1];

    if (!idToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Verify the ID token
    const decodedToken = await auth.verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // Get user data from Firestore
    const userDoc = await db.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data();
    res.status(200).json(userData);
  } catch (error) {
    console.error('Error retrieving user information:', error);
    res.status(500).json({ error: 'Failed to retrieve user information' });
  }
});

module.exports = router;

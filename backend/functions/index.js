const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Authentication endpoints
// /auth/login
app.post('/login', async (req, res) => {
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
app.post('/register', async (req, res) => {
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
app.get('/me', async (req, res) => {
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

// Teams endpoints
// /teams
app.get('/teams', async (req, res) => {
  try {
    const teamsSnapshot = await db.collection('teams').get();
    const teams = teamsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(teams);
  } catch (error) {
    console.error('Error fetching teams:', error);
    res.status(500).json({ error: 'Failed to fetch teams' });
  }
});

app.post('/teams', async (req, res) => {
  try {
    const teamData = req.body;
    const teamRef = await db.collection('teams').add(teamData);
    res.status(201).json({ id: teamRef.id, ...teamData });
  } catch (error) {
    console.error('Error creating team:', error);
    res.status(500).json({ error: 'Failed to create team' });
  }
});

// /teams/{teamId}
app.get('/teams/:teamId', async (req, res) => {
  try {
    const teamDoc = await db.collection('teams').doc(req.params.teamId).get();

    if (!teamDoc.exists) {
      return res.status(404).json({ error: 'Team not found' });
    }

    res.status(200).json({ id: teamDoc.id, ...teamDoc.data() });
  } catch (error) {
    console.error('Error fetching team:', error);
    res.status(500).json({ error: 'Failed to fetch team' });
  }
});

app.put('/teams/:teamId', async (req, res) => {
  try {
    const teamData = req.body;
    await db.collection('teams').doc(req.params.teamId).update(teamData);
    res.status(200).json({ id: req.params.teamId, ...teamData });
  } catch (error) {
    console.error('Error updating team:', error);
    res.status(500).json({ error: 'Failed to update team' });
  }
});

app.delete('/teams/:teamId', async (req, res) => {
  try {
    await db.collection('teams').doc(req.params.teamId).delete();
    res.status(204).send(); // No content
  } catch (error) {
    console.error('Error deleting team:', error);
    res.status(500).json({ error: 'Failed to delete team' });
  }
});

// /teams/{teamId}/members
app.get('/teams/:teamId/members', async (req, res) => {
  try {
    // Assuming you have a subcollection 'members' under each team document
    const membersSnapshot = await db.collection('teams').doc(req.params.teamId).collection('members').get();
    const members = membersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(members);
  } catch (error) {
    console.error('Error fetching team members:', error);
    res.status(500).json({ error: 'Failed to fetch team members' });
  }
});

app.post('/teams/:teamId/members', async (req, res) => {
  try {
    const memberId = req.body.memberId; // Assuming you're sending the memberId in the request body

    if (!memberId) {
      return res.status(400).json({ error: 'memberId is required' });
    }

    // Add the member to the team's 'members' subcollection
    await db.collection('teams').doc(req.params.teamId).collection('members').doc(memberId).set({
      // Add any relevant member data here, e.g., role, joinedAt, etc.
    });

    res.status(201).json({ message: 'Member added to team successfully' });
  } catch (error) {
    console.error('Error adding member to team:', error);
    res.status(500).json({ error: 'Failed to add member to team' });
  }
});

app.delete('/teams/:teamId/members/:memberId', async (req, res) => {
  try {
    // Delete the member from the team's 'members' subcollection
    await db.collection('teams').doc(req.params.teamId).collection('members').doc(req.params.memberId).delete();

    res.status(204).send(); // No content
  } catch (error) {
    console.error('Error removing member from team:', error);
    res.status(500).json({ error: 'Failed to remove member from team' });
  }
});

// Users endpoints
// /users
app.get('/users', async (req, res) => {
  try {
    const usersSnapshot = await db.collection('users').get();
    const users = usersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

exports.api = functions.https.onRequest(app);

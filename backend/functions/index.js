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

// Import and use the auth routes
const authRoutes = require('./routes/auth');
app.use('/auth', authRoutes);

// Import and use the teams routes
const teamsRoutes = require('./routes/teams');
app.use('/teams', teamsRoutes);

// Import and use the admins routes
const adminsRoutes = require('./routes/admins');
app.use('/admins', adminsRoutes);

exports.api = functions.https.onRequest(app);

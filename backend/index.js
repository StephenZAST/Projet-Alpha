const express = require('express');
const cors = require('cors');
const { createServer } = require('@supabase/supabase-js');

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

const supabaseUrl = 'https://your-supabase-url.supabase.co';
const supabaseKey = 'your-supabase-key';
const supabaseSecret = 'your-supabase-secret';

const supabase = createServer(supabaseUrl, supabaseKey, supabaseSecret);

// Authentication endpoints
// /auth/login
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const { data, error } = await supabase.auth.signIn({ email, password });

    if (error) {
      console.error('Error during login:', error);
      res.status(500).json({ error: 'Failed to log in' });
    } else {
      res.status(200).json({ token: data.session.token });
    }
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

    const { data, error } = await supabase.auth.signUp({ email, password });

    if (error) {
      console.error('Error during registration:', error);
      res.status(500).json({ error: 'Failed to register' });
    } else {
      res.status(201).json({ token: data.session.token });
    }
  } catch (error) {
    console.error('Error during registration:', error);
    res.status(500).json({ error: 'Failed to register' });
  }
});

// /auth/me
app.get('/me', async (req, res) => {
  // Implement logic to retrieve current user information
});

exports.api = app;

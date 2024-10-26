import express from 'express';
import { authenticateUser, requireAdmin } from '../middleware/auth';

const router = express.Router();

// Protected route requiring authentication
router.get('/profile', authenticateUser, (req, res) => {
  res.json({ user: req.user });
});

// Protected route requiring admin privileges
router.get('/all', authenticateUser, requireAdmin, (req, res) => {
  // Only admins can access this route
});

export default router;
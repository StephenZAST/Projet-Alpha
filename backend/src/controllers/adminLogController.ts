import { Request, Response } from 'express';
import { db } from '../config/firebase';
import { User } from '../models/user';

export class AdminLogController {
  async getLogs(req: Request, res: Response) {
    try {
      const logsSnapshot = await db.collection('admin_logs')
        .orderBy('createdAt', 'desc')
        .limit(100)
        .get();

      const logs = logsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json(logs);
    } catch (error) {
      console.error('Error getting admin logs:', error);
      res.status(500).json({ error: 'Failed to retrieve admin logs' });
    }
  }

  async getLogById(req: Request, res: Response) {
    try {
      const logDoc = await db.collection('admin_logs').doc(req.params.id).get();
      
      if (!logDoc.exists) {
        return res.status(404).json({ error: 'Log not found' });
      }

      res.json({
        id: logDoc.id,
        ...logDoc.data()
      });
    } catch (error) {
      console.error('Error getting admin log:', error);
      res.status(500).json({ error: 'Failed to retrieve admin log' });
    }
  }

  async createLog(req: Request, res: Response) {
    try {
      const { action, details } = req.body;
      const user = req.user as User;

      const logRef = db.collection('admin_logs').doc();
      const now = new Date();

      await logRef.set({
        id: logRef.id,
        adminId: user.id,
        adminName: `${user.firstName} ${user.lastName}`,
        action,
        details,
        createdAt: now,
        updatedAt: now
      });

      res.status(201).json({
        id: logRef.id,
        message: 'Admin log created successfully'
      });
    } catch (error) {
      console.error('Error creating admin log:', error);
      res.status(500).json({ error: 'Failed to create admin log' });
    }
  }

  async updateLog(req: Request, res: Response) {
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
        updatedAt: new Date()
      });

      res.json({
        id: logRef.id,
        message: 'Admin log updated successfully'
      });
    } catch (error) {
      console.error('Error updating admin log:', error);
      res.status(500).json({ error: 'Failed to update admin log' });
    }
  }

  async deleteLog(req: Request, res: Response) {
    try {
      const logRef = db.collection('admin_logs').doc(req.params.id);
      
      const logDoc = await logRef.get();
      if (!logDoc.exists) {
        return res.status(404).json({ error: 'Log not found' });
      }

      await logRef.delete();

      res.json({
        message: 'Admin log deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting admin log:', error);
      res.status(500).json({ error: 'Failed to delete admin log' });
    }
  }

  async getRecentActivity(req: Request, res: Response) {
    try {
      const { limit = 10 } = req.query;
      const adminId = req.user?.id;

      if (!adminId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const logsSnapshot = await db.collection('admin_logs')
        .where('adminId', '==', adminId)
        .orderBy('createdAt', 'desc')
        .limit(Number(limit))
        .get();

      const logs = logsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json(logs);
    } catch (error) {
      console.error('Error getting recent activity:', error);
      res.status(500).json({ error: 'Failed to retrieve recent activity' });
    }
  }

  async getFailedLoginAttempts(req: Request, res: Response) {
    try {
      const { adminId } = req.params;
      const { days = 7 } = req.query;

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - Number(days));

      const logsSnapshot = await db.collection('admin_logs')
        .where('adminId', '==', adminId)
        .where('action', '==', 'FAILED_LOGIN')
        .where('createdAt', '>=', startDate)
        .orderBy('createdAt', 'desc')
        .get();

      const logs = logsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json(logs);
    } catch (error) {
      console.error('Error getting failed login attempts:', error);
      res.status(500).json({ error: 'Failed to retrieve failed login attempts' });
    }
  }
}

import { db } from './firebase';
import { Team } from '../models/team';
import { AppError, errorCodes } from '../utils/errors';
import * as admin from 'firebase-admin';

export class TeamService {
  private teamsRef = db.collection('teams');

  async createTeam(teamData: Omit<Team, 'id' | 'createdAt' | 'updatedAt'>): Promise<Team> {
    try {
      const newTeam: Omit<Team, 'id'> = {
        ...teamData,
        adminIds: [],
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
      };

      const teamRef = await this.teamsRef.add(newTeam);
      // Assign the generated ID after creation
      return { ...newTeam, id: teamRef.id } as Team;
    } catch (error) {
      console.error('Error creating team:', error);
      throw new AppError(500, 'Failed to create team', errorCodes.DATABASE_ERROR);
    }
  }

  async getTeamById(teamId: string): Promise<Team | null> {
    try {
      const teamDoc = await this.teamsRef.doc(teamId).get();

      if (!teamDoc.exists) {
        return null;
      }

      return { id: teamDoc.id, ...teamDoc.data() } as Team;
    } catch (error) {
      console.error('Error fetching team:', error);
      throw new AppError(500, 'Failed to fetch team', errorCodes.DATABASE_ERROR);
    }
  }

  async updateTeam(teamId: string, teamData: Partial<Team>): Promise<Team> {
    try {
      const teamRef = this.teamsRef.doc(teamId);
      await teamRef.update({
        ...teamData,
        updatedAt: admin.firestore.Timestamp.now(),
      });

      const updatedTeam = await teamRef.get();
      return { id: teamId, ...updatedTeam.data() } as Team;
    } catch (error) {
      console.error('Error updating team:', error);
      throw new AppError(500, 'Failed to update team', errorCodes.DATABASE_ERROR);
    }
  }

  async deleteTeam(teamId: string): Promise<void> {
    try {
      await this.teamsRef.doc(teamId).delete();
    } catch (error) {
      console.error('Error deleting team:', error);
      throw new AppError(500, 'Failed to delete team', errorCodes.DATABASE_ERROR);
    }
  }

  async addAdminToTeam(teamId: string, adminId: string): Promise<void> {
    try {
      const teamRef = this.teamsRef.doc(teamId);
      const teamDoc = await teamRef.get();

      if (!teamDoc.exists) {
        throw new AppError(404, 'Team not found', errorCodes.TEAM_NOT_FOUND);
      }

      const teamData = teamDoc.data() as Team;
      const adminIds = teamData.adminIds || [];

      if (adminIds.includes(adminId)) {
        throw new AppError(400, 'Admin is already a member of this team', errorCodes.ADMIN_ALREADY_IN_TEAM);
      }

      await teamRef.update({
        adminIds: [...adminIds, adminId],
        updatedAt: admin.firestore.Timestamp.now(),
      });

      // Update user's teamId
      await db.collection('users').doc(adminId).update({ teamId });
    } catch (error) {
      if (error instanceof AppError) throw error;
      console.error('Error adding admin to team:', error);
      throw new AppError(500, 'Failed to add admin to team', errorCodes.DATABASE_ERROR);
    }
  }

  async removeAdminFromTeam(teamId: string, adminId: string): Promise<void> {
    try {
      const teamRef = this.teamsRef.doc(teamId);
      const teamDoc = await teamRef.get();

      if (!teamDoc.exists) {
        throw new AppError(404, 'Team not found', errorCodes.TEAM_NOT_FOUND);
      }

      const teamData = teamDoc.data() as Team;
      const adminIds = teamData.adminIds || [];

      if (!adminIds.includes(adminId)) {
        throw new AppError(400, 'Admin is not a member of this team', errorCodes.ADMIN_NOT_IN_TEAM);
      }

      const updatedAdminIds = adminIds.filter(id => id !== adminId);

      await teamRef.update({
        adminIds: updatedAdminIds,
        updatedAt: admin.firestore.Timestamp.now(),
      });

      // Update user's teamId
      await db.collection('users').doc(adminId).update({ teamId: null });
    } catch (error) {
      if (error instanceof AppError) throw error;
      console.error('Error removing admin from team:', error);
      throw new AppError(500, 'Failed to remove admin from team', errorCodes.DATABASE_ERROR);
    }
  }

  async getTeamsForAdmin(adminId: string): Promise<Team[]> {
    try {
      const teamsSnapshot = await this.teamsRef.where('adminIds', 'array-contains', adminId).get();
      return teamsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Team));
    } catch (error) {
      console.error('Error fetching teams for admin:', error);
      throw new AppError(500, 'Failed to fetch teams for admin', errorCodes.DATABASE_ERROR);
    }
  }
}

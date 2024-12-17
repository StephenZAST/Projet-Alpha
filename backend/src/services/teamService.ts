import { createClient } from '@supabase/supabase-js';
import { Team } from '../models/team';
import { AppError, errorCodes } from '../utils/errors';
import { PostgrestError } from '@supabase/supabase-js';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const teamsTable = 'teams';
const usersTable = 'users';

export class TeamService {
  private teamsRef = supabase.from(teamsTable);
  private usersRef = supabase.from(usersTable);

  /**
   * Create a new team
   */
  async createTeam(teamData: Omit<Team, 'id' | 'createdAt' | 'updatedAt'>): Promise<Team> {
    try {
      const newTeam: Omit<Team, 'id'> = {
        ...teamData,
        adminIds: [],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const { data, error } = await this.teamsRef.insert([newTeam]).select().single();

      if (error) {
        throw new AppError(500, 'Failed to create team', errorCodes.TEAM_CREATION_FAILED);
      }

      return { ...newTeam, id: data.id } as Team;
    } catch (error) {
      console.error('Error creating team:', error);
      throw error;
    }
  }

  /**
   * Get team by id
   */
  async getTeamById(teamId: string): Promise<Team | null> {
    try {
      const { data, error } = await this.teamsRef.select('*').eq('id', teamId).single();

      if (error) {
        if ((error as PostgrestError).code === '404') {
          return null;
        }
        throw new AppError(500, 'Failed to fetch team', errorCodes.TEAM_NOT_FOUND);
      }

      return { id: teamId, ...data } as Team;
    } catch (error) {
      console.error('Error fetching team:', error);
      throw error;
    }
  }

  /**
   * Update a team
   */
  async updateTeam(teamId: string, teamData: Partial<Team>): Promise<Team> {
    try {
      const { data, error } = await this.teamsRef.update({
        ...teamData,
        updatedAt: new Date().toISOString(),
      }).eq('id', teamId).select().single();

      if (error) {
        throw new AppError(500, 'Failed to update team', errorCodes.TEAM_UPDATE_FAILED);
      }

      return { id: teamId, ...data } as Team;
    } catch (error) {
      console.error('Error updating team:', error);
      throw error;
    }
  }

  /**
   * Delete a team
   */
  async deleteTeam(teamId: string): Promise<void> {
    try {
      const { error } = await this.teamsRef.delete().eq('id', teamId);

      if (error) {
        throw new AppError(500, 'Failed to delete team', errorCodes.TEAM_DELETION_FAILED);
      }
    } catch (error) {
      console.error('Error deleting team:', error);
      throw error;
    }
  }

  /**
   * Add admin to team
   */
  async addAdminToTeam(teamId: string, adminId: string): Promise<void> {
    try {
      const { data, error } = await this.teamsRef.select('*').eq('id', teamId).single();

      if (error) {
        if ((error as PostgrestError).code === '404') {
          throw new AppError(404, 'Team not found', errorCodes.TEAM_NOT_FOUND);
        }
        throw new AppError(500, 'Failed to fetch team', errorCodes.DATABASE_ERROR);
      }

      const teamData = data as Team;
      const adminIds = teamData.adminIds || [];

      if (adminIds.includes(adminId)) {
        throw new AppError(400, 'Admin is already a member of this team', errorCodes.ADMIN_ALREADY_IN_TEAM);
      }

      await this.teamsRef.update({
        adminIds: [...adminIds, adminId],
        updatedAt: new Date().toISOString(),
      }).eq('id', teamId);

      // Update user's teamId
      await this.usersRef.update({ teamId }).eq('id', adminId);
    } catch (error) {
      if (error instanceof AppError) throw error;
      console.error('Error adding admin to team:', error);
      throw new AppError(500, 'Failed to add admin to team', errorCodes.DATABASE_ERROR);
    }
  }

  /**
   * Remove admin from team
   */
  async removeAdminFromTeam(teamId: string, adminId: string): Promise<void> {
    try {
      const { data, error } = await this.teamsRef.select('*').eq('id', teamId).single();

      if (error) {
        if ((error as PostgrestError).code === '404') {
          throw new AppError(404, 'Team not found', errorCodes.TEAM_NOT_FOUND);
        }
        throw new AppError(500, 'Failed to fetch team', errorCodes.DATABASE_ERROR);
      }

      const teamData = data as Team;
      const adminIds = teamData.adminIds || [];

      if (!adminIds.includes(adminId)) {
        throw new AppError(400, 'Admin is not a member of this team', errorCodes.ADMIN_NOT_IN_TEAM);
      }

      const updatedAdminIds = adminIds.filter(id => id !== adminId);

      await this.teamsRef.update({
        adminIds: updatedAdminIds,
        updatedAt: new Date().toISOString(),
      }).eq('id', teamId);

      // Update user's teamId
      await this.usersRef.update({ teamId: null }).eq('id', adminId);
    } catch (error) {
      if (error instanceof AppError) throw error;
      console.error('Error removing admin from team:', error);
      throw new AppError(500, 'Failed to remove admin from team', errorCodes.DATABASE_ERROR);
    }
  }

  /**
   * Get teams for admin
   */
  async getTeamsForAdmin(adminId: string): Promise<Team[]> {
    try {
      const { data, error } = await this.teamsRef.select('*').in('adminIds', [adminId]);

      if (error) {
        throw new AppError(500, 'Failed to fetch teams for admin', errorCodes.DATABASE_ERROR);
      }

      return data.map(doc => ({ id: doc.id, ...doc } as Team));
    } catch (error) {
      console.error('Error fetching teams for admin:', error);
      throw error;
    }
  }
}

export const teamService = new TeamService();

const express = require('express');
const admin = require('firebase-admin');
const { TeamService } = require('../../src/services/teamService'); // Import TeamService
const { AppError } = require('../../src/utils/errors'); // Import AppError

const db = admin.firestore();
const router = express.Router();
const teamService = new TeamService(); // Create an instance of TeamService

// /teams
router.get('/', async (req, res) => {
  try {
    const teamsSnapshot = await db.collection('teams').get();
    const teams = teamsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(teams);
  } catch (error) {
    console.error('Error fetching teams:', error);
    res.status(500).json({ error: 'Failed to fetch teams' });
  }
});

router.post('/', async (req, res) => {
  try {
    const teamData = req.body;
    const team = await teamService.createTeam(teamData); // Use teamService to create a team
    res.status(201).json(team);
  } catch (error) {
    console.error('Error creating team:', error);
    res.status(500).json({ error: 'Failed to create team' });
  }
});

// /teams/{teamId}
router.get('/:teamId', async (req, res) => {
  try {
    const team = await teamService.getTeamById(req.params.teamId); // Use teamService to get a team by ID

    if (!team) {
      return res.status(404).json({ error: 'Team not found' });
    }

    res.status(200).json(team);
  } catch (error) {
    console.error('Error fetching team:', error);
    res.status(500).json({ error: 'Failed to fetch team' });
  }
});

router.put('/:teamId', async (req, res) => {
  try {
    const teamData = req.body;
    const team = await teamService.updateTeam(req.params.teamId, teamData); // Use teamService to update a team
    res.status(200).json(team);
  } catch (error) {
    console.error('Error updating team:', error);
    res.status(500).json({ error: 'Failed to update team' });
  }
});

router.delete('/:teamId', async (req, res) => {
  try {
    await teamService.deleteTeam(req.params.teamId); // Use teamService to delete a team
    res.status(204).send(); // No content
  } catch (error) {
    console.error('Error deleting team:', error);
    res.status(500).json({ error: 'Failed to delete team' });
  }
});

// /teams/{teamId}/members
router.get('/:teamId/members', async (req, res) => {
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

router.post('/:teamId/members', async (req, res) => {
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

router.delete('/:teamId/members/:memberId', async (req, res) => {
  try {
    // Delete the member from the team's 'members' subcollection
    await db.collection('teams').doc(req.params.teamId).collection('members').doc(req.params.memberId).delete();

    res.status(204).send(); // No content
  } catch (error) {
    console.error('Error removing member from team:', error);
    res.status(500).json({ error: 'Failed to remove member from team' });
  }
});

// /teams/{teamId}/admins
router.post('/:teamId/admins', async (req, res) => {
  try {
    const adminId = req.body.adminId;

    if (!adminId) {
      return res.status(400).json({ error: 'adminId is required' });
    }

    await teamService.addAdminToTeam(req.params.teamId, adminId);
    res.status(201).json({ message: 'Admin added to team successfully' });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error adding admin to team:', error);
    res.status(500).json({ error: 'Failed to add admin to team' });
  }
});

router.delete('/:teamId/admins/:adminId', async (req, res) => {
  try {
    await teamService.removeAdminFromTeam(req.params.teamId, req.params.adminId);
    res.status(204).send(); // No content
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error removing admin from team:', error);
    res.status(500).json({ error: 'Failed to remove admin from team' });
  }
});

module.exports = router;

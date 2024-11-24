import React, { useState } from 'react';
import styles from './style/TeamManagement.module.css';

interface Team {
  id: string;
  name: string;
  description: string;
  members: string[];
}

const TeamManagement: React.FC = () => {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [teams, setTeams] = useState<Team[]>([
    {
      id: '1',
      name: 'Team A',
      description: 'This is Team A',
      members: ['John Doe', 'Jane Doe'],
    },
    {
      id: '2',
      name: 'Team B',
      description: 'This is Team B',
      members: ['Peter Pan', 'Wendy Darling'],
    },
  ]);

  const [newTeamName, setNewTeamName] = useState('');
  const [newTeamDescription, setNewTeamDescription] = useState('');
  const [editingTeamId, setEditingTeamId] = useState<string | null>(null);
  const [editTeamName, setEditTeamName] = useState('');
  const [editTeamDescription, setEditTeamDescription] = useState('');

  const handleAddTeam = () => {
    const newTeam: Team = {
      id: (teams.length + 1).toString(),
      name: newTeamName,
      description: newTeamDescription,
      members: [],
    };

    setTeams([...teams, newTeam]);
    setNewTeamName('');
    setNewTeamDescription('');
  };

  const handleEditTeam = (id: string) => {
    const teamToEdit = teams.find((team) => team.id === id);
    if (teamToEdit) {
      setEditingTeamId(id);
      setEditTeamName(teamToEdit.name);
      setEditTeamDescription(teamToEdit.description);
    }
  };

  const handleSaveEdit = () => {
    setTeams(
      teams.map((team) =>
        team.id === editingTeamId
          ? { ...team, name: editTeamName, description: editTeamDescription }
          : team
      )
    );
    setEditingTeamId(null);
    setEditTeamName('');
    setEditTeamDescription('');
  };

  const handleCancelEdit = () => {
    setEditingTeamId(null);
    setEditTeamName('');
    setEditTeamDescription('');
  };

  const handleDeleteTeam = (id: string) => {
    if (window.confirm('Are you sure you want to delete this team?')) {
      setTeams(teams.filter((team) => team.id !== id));
    }
  };

  return (
    <div className={styles['team-management']}>
      <h2>Team Management</h2>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Members</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {teams.map((team) => (
            <tr key={team.id}>
              <td>
                {editingTeamId === team.id ? (
                  <input
                    type="text"
                    value={editTeamName}
                    onChange={(e) => setEditTeamName(e.target.value)}
                  />
                ) : (
                  team.name
                )}
              </td>
              <td>
                {editingTeamId === team.id ? (
                  <input
                    type="text"
                    value={editTeamDescription}
                    onChange={(e) => setEditTeamDescription(e.target.value)}
                  />
                ) : (
                  team.description
                )}
              </td>
              <td>{team.members.join(', ')}</td>
              <td>
                {editingTeamId === team.id ? (
                  <>
                    <button onClick={handleSaveEdit}>Save</button>
                    <button onClick={handleCancelEdit}>Cancel</button>
                  </>
                ) : (
                  <>
                    <button onClick={() => handleEditTeam(team.id)}>Edit</button>
                    <button onClick={() => handleDeleteTeam(team.id)}>
                      Delete
                    </button>
                  </>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <h3>Add New Team</h3>
      <div>
        <label htmlFor="teamName">Team Name:</label>
        <input
          type="text"
          id="teamName"
          value={newTeamName}
          onChange={(e) => setNewTeamName(e.target.value)}
        />
      </div>
      <div>
        <label htmlFor="teamDescription">Description:</label>
        <input
          type="text"
          id="teamDescription"
          value={newTeamDescription}
          onChange={(e) => setNewTeamDescription(e.target.value)}
        />
      </div>
      <button onClick={handleAddTeam}>Add Team</button>
    </div>
  );
};

export default TeamManagement;

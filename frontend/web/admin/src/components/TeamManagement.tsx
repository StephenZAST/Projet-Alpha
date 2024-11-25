import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  fetchTeams,
  addTeam,
  updateTeam,
  deleteTeam,
} from '../redux/slices/teamSlice';
import styles from './style/TeamManagement.module.css';
import { RootState, AppDispatch } from '../redux/store';

interface Team {
  id: string;
  name: string;
  description: string;
  members: string[];
}

const TeamManagement: React.FC = () => {
  const dispatch: AppDispatch = useDispatch();
  const teams = useSelector((state: RootState) => state.teams.teams);
  const status = useSelector((state: RootState) => state.teams.status);
  const error = useSelector((state: RootState) => state.teams.error);

  const [newTeamName, setNewTeamName] = useState('');
  const [newTeamDescription, setNewTeamDescription] = useState('');
  const [editingTeamId, setEditingTeamId] = useState<string | null>(null);
  const [editTeamName, setEditTeamName] = useState('');
  const [editTeamDescription, setEditTeamDescription] = useState('');

  useEffect(() => {
    if (status === 'idle') {
      dispatch(fetchTeams());
    }
  }, [status, dispatch]);

  const handleAddTeam = () => {
    const newTeam: Team = {
      id: '', // Let Firebase generate the ID
      name: newTeamName,
      description: newTeamDescription,
      members: [],
    };

    dispatch(addTeam(newTeam));
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
    if (editingTeamId) {
      const updatedTeam: Team = {
        id: editingTeamId,
        name: editTeamName,
        description: editTeamDescription,
        members: [], // Assuming members are not edited here
      };

      dispatch(updateTeam(updatedTeam));
      setEditingTeamId(null);
      setEditTeamName('');
      setEditTeamDescription('');
    }
  };

  const handleCancelEdit = () => {
    setEditingTeamId(null);
    setEditTeamName('');
    setEditTeamDescription('');
  };

  const handleDeleteTeam = (id: string) => {
    if (window.confirm('Are you sure you want to delete this team?')) {
      dispatch(deleteTeam(id));
    }
  };

  let content;

  if (status === 'loading') {
    content = <div>Loading...</div>;
  } else if (status === 'succeeded') {
    content = (
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
    );
  } else if (status === 'failed') {
    content = <div>{error}</div>;
  }

  return (
    <div className={styles['team-management']}>
      <h2>Team Management</h2>
      {content}
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

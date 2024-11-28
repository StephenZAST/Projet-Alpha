import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Tablecontainer';
import styles from './style/TeamCommunication.module.css';

interface TeamCommunicationMessage {
  id: string;
  sender: string;
  content: string;
}

const TeamCommunication: React.FC = () => {
  const [teamCommunicationMessages, setTeamCommunicationMessages] = useState<TeamCommunicationMessage[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchTeamCommunicationMessages = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/team-communication');
        setTeamCommunicationMessages(response.data);
      } catch (error) {
        if (error instanceof Error) {
          setError(error);
        } else {
          setError(new Error('Unknown error'));
        }
      } finally {
        setLoading(false);
      }
    };
    fetchTeamCommunicationMessages();
  }, []);

  const columns = [
    { key: 'id', label: 'Message ID' },
    { key: 'sender', label: 'Sender' },
    { key: 'content', label: 'Content' },
  ];

  return (
    <div className={styles.teamCommunicationContainer}>
      <h2>Team Communication</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={teamCommunicationMessages} columns={columns} />
      )}
    </div>
  );
};

export default TeamCommunication;

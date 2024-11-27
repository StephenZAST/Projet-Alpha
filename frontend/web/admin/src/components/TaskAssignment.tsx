import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/TaskAssignment.module.css';

interface Task {
  id: string;
  name: string;
  status: string;
}

const TaskAssignment: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchTasks = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/tasks');
        setTasks(response.data);
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
    fetchTasks();
  }, []);

  const columns = [
    { key: 'id', label: 'Task ID' },
    { key: 'name', label: 'Name' },
    { key: 'status', label: 'Status' },
  ];

  return (
    <div className={styles.taskAssignmentContainer}>
      <h2>Task Assignment</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={tasks} columns={columns} />
      )}
    </div>
  );
};

export default TaskAssignment;

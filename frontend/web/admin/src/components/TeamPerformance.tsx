import React from 'react';
import styles from './style/TeamPerformance.module.css';

interface TeamPerformanceProps {
  teamName: string;
  teamMembers: string[];
  teamPerformance: number;
}

const TeamPerformance: React.FC<TeamPerformanceProps> = ({
  teamName,
  teamMembers,
  teamPerformance,
}) => {
  return (
    <div className={styles.teamPerformanceContainer}>
      <h2>{teamName}</h2>
      <p>Team Members: {teamMembers.join(', ')}</p>
      <p>Team Performance: {teamPerformance}%</p>
    </div>
  );
};

export default TeamPerformance;

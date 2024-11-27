import React from 'react';
import { useForm } from 'react-hook-form';
import styles from './style/SupervisorConfig.module.css';

interface SupervisorConfigForm {
  supervisorName: string;
  email: string;
  phoneNumber: string;
}

const SupervisorConfig: React.FC = () => {
  const { register, handleSubmit, formState: { errors } } = useForm<SupervisorConfigForm>();

  const onSubmit = async (data: SupervisorConfigForm) => {
    // Submit the form data to the API endpoint
    console.log(data);
  };

  return (
    <div className={styles.supervisorConfigContainer}>
      <h2>Supervisor Configuration</h2>
      <form onSubmit={handleSubmit(onSubmit)}>
        <label>Supervisor Name:</label>
        <input type="text" {...register('supervisorName')} />
        {errors.supervisorName && <p>{errors.supervisorName.message}</p>}
        <label>Email:</label>
        <input type="email" {...register('email')} />
        {errors.email && <p>{errors.email.message}</p>}
        <label>Phone Number:</label>
        <input type="text" {...register('phoneNumber')} />
        {errors.phoneNumber && <p>{errors.phoneNumber.message}</p>}
        <button type="submit">Save Changes</button>
      </form>
    </div>
  );
};

export default SupervisorConfig;

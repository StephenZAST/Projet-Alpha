import React from 'react';
import { useForm } from 'react-hook-form';
import styles from '../style/Settings.module.css';

interface SettingsForm {
  username: string;
  email: string;
  password: string;
}

const Settings: React.FC = () => {
  const { register, handleSubmit, formState: { errors } } = useForm<SettingsForm>();

  const onSubmit = async (data: SettingsForm) => {
    // Submit the form data to the API endpoint
    console.log(data);
  };

  return (
    <div className={styles.settingsContainer}>
      <h2>Settings</h2>
      <form onSubmit={handleSubmit(onSubmit)}>
        <label>Username:</label>
        <input type="text" {...register('username')} />
        {errors.username && <p>{errors.username.message}</p>}
        <label>Email:</label>
        <input type="email" {...register('email')} />
        {errors.email && <p>{errors.email.message}</p>}
        <label>Password:</label>
        <input type="password" {...register('password')} />
        {errors.password && <p>{errors.password.message}</p>}
        <button type="submit">Save Changes</button>
      </form>
    </div>
  );
};

export default Settings;

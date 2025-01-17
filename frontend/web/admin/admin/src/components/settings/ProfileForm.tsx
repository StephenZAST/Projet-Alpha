import React from 'react';
import { useForm } from 'react-hook-form';
import { UserProfile } from '../../types/settings';
import { Button } from '../common/Button';
import { Input } from '../common/Input';
import { colors } from '../../theme/colors';

interface ProfileFormProps {
  profile?: UserProfile;
  loading: boolean;
  onSubmit: (data: Partial<UserProfile>) => Promise<void>;
}

export const ProfileForm = ({ profile, loading, onSubmit }: ProfileFormProps) => {
  const { register, handleSubmit, formState: { errors } } = useForm({
    defaultValues: profile || {
      firstName: '',
      lastName: '',
      email: ''
    }
  });

  return (
    <div style={{
      backgroundColor: colors.white,
      padding: '24px',
      borderRadius: '12px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
    }}>
      <form onSubmit={handleSubmit(onSubmit)} style={{ maxWidth: '500px' }}>
        <Input
          label="First Name"
          {...register('firstName', { required: 'First name is required' })}
          error={errors.firstName?.message}
        />

        <Input
          label="Last Name"
          {...register('lastName', { required: 'Last name is required' })}
          error={errors.lastName?.message}
        />

        <Input
          label="Email"
          type="email"
          {...register('email', { 
            required: 'Email is required',
            pattern: { 
              value: /^\S+@\S+$/i, 
              message: 'Invalid email format' 
            }
          })}
          error={errors.email?.message}
        />

        <div style={{ marginTop: '24px' }}>
          <Button 
            type="submit" 
            disabled={loading}
            style={{ width: '100%' }}
          >
            {loading ? 'Saving...' : 'Save Changes'}
          </Button>
        </div>
      </form>
    </div>
  );
};

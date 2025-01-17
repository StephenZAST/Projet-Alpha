import { useForm } from 'react-hook-form';
import { UserSettings } from '../../types/settings';
import { Button } from '../common/Button';
import { colors } from '../../theme/colors';

interface PreferencesFormProps {
  settings?: UserSettings;
  loading: boolean;
  onSubmit: (data: Partial<UserSettings>) => Promise<void>;
}

export const PreferencesForm = ({ settings, loading, onSubmit }: PreferencesFormProps) => {
  const { register, handleSubmit } = useForm({
    defaultValues: settings || {
      notifications: {
        email: true,
        push: true
      },
      theme: 'light',
      language: 'en'
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
        <div style={{ marginBottom: '24px' }}>
          <h3 style={{ marginBottom: '16px', color: colors.gray700 }}>
            Notifications
          </h3>
          <div style={{ 
            display: 'flex', 
            flexDirection: 'column', 
            gap: '12px' 
          }}>
            <label style={{ 
              display: 'flex', 
              alignItems: 'center',
              gap: '8px',
              cursor: 'pointer'
            }}>
              <input 
                type="checkbox" 
                {...register('notifications.email')} 
              />
              Email Notifications
            </label>
            <label style={{ 
              display: 'flex', 
              alignItems: 'center',
              gap: '8px',
              cursor: 'pointer'
            }}>
              <input 
                type="checkbox" 
                {...register('notifications.push')} 
              />
              Push Notifications
            </label>
          </div>
        </div>

        <div style={{ marginBottom: '24px' }}>
          <h3 style={{ marginBottom: '16px', color: colors.gray700 }}>
            Theme
          </h3>
          <select 
            {...register('theme')}
            style={{
              width: '100%',
              padding: '8px',
              borderRadius: '8px',
              border: `1px solid ${colors.gray300}`
            }}
          >
            <option value="light">Light</option>
            <option value="dark">Dark</option>
          </select>
        </div>

        <div style={{ marginBottom: '24px' }}>
          <h3 style={{ marginBottom: '16px', color: colors.gray700 }}>
            Language
          </h3>
          <select 
            {...register('language')}
            style={{
              width: '100%',
              padding: '8px',
              borderRadius: '8px',
              border: `1px solid ${colors.gray300}`
            }}
          >
            <option value="en">English</option>
            <option value="fr">French</option>
          </select>
        </div>

        <Button 
          type="submit" 
          disabled={loading}
          style={{ width: '100%' }}
        >
          {loading ? 'Saving...' : 'Save Preferences'}
        </Button>
      </form>
    </div>
  );
};

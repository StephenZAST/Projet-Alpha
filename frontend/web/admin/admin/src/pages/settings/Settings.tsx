import { useState } from 'react';
import { useSettings } from '../../hooks/useSettings';
import { ProfileForm } from '../../components/settings/ProfileForm';
import { PreferencesForm } from '../../components/settings/PreferencesForm';
import { colors } from '../../theme/colors';
import { SettingsTab } from '../../types/settings';

export const Settings = () => {
  const { settings, profile, loading, error, updateSettings, updateProfile } = useSettings();
  const [activeTab, setActiveTab] = useState<SettingsTab>('profile');

  const tabs = [
    { id: 'profile', label: 'Profile Settings' },
    { id: 'preferences', label: 'Preferences' }
  ];

  if (error) {
    return (
      <div style={{ padding: '24px', color: colors.error }}>
        {error}
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <h1 style={{ marginBottom: '24px' }}>Settings</h1>
      
      <div style={{ 
        display: 'flex', 
        gap: '16px', 
        marginBottom: '24px',
        backgroundColor: colors.white,
        padding: '8px',
        borderRadius: '8px'
      }}>
        {tabs.map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as SettingsTab)}
            style={{
              backgroundColor: activeTab === tab.id ? colors.primary : colors.white,
              color: activeTab === tab.id ? colors.white : colors.gray700,
              padding: '8px 16px',
              borderRadius: '4px',
              border: 'none',
              cursor: 'pointer'
            }}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div>
        {activeTab === 'profile' ? (
          <ProfileForm 
            profile={profile} 
            loading={loading}
            onSubmit={updateProfile}
          />
        ) : (
          <PreferencesForm 
            settings={settings}
            loading={loading}
            onSubmit={updateSettings}
          />
        )}
      </div>
    </div>
  );
};

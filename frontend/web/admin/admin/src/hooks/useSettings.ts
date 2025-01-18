import { useState, useEffect } from 'react';
import api from '../utils/api';
import { UserSettings, UserProfile } from '../types/settings';

export const useSettings = () => {
  const [settings, setSettings] = useState<UserSettings | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchSettings();
    fetchProfile();
  }, []);

  const fetchSettings = async () => {
    try {
      const response = await api.get<UserSettings>('/admin/settings');
      setSettings(response);
      setError(null);
    } catch (err: Error) {
      setError(err.message);
    }
  };

  const fetchProfile = async () => {
    try {
      const response = await api.get<UserProfile>('/admin/profile');
      setProfile(response);
      setError(null);
    } catch (err: unknown) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('An unknown error occurred');
      }
    }
  };

  const updateSettings = async (newSettings: Partial<UserSettings>) => {
    setLoading(true);
    try {
      const response = await api.put<UserSettings>('/admin/settings', newSettings);
      setSettings(response);
      setError(null);
    } catch (err: Error) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  };

  const updateProfile = async (newProfile: Partial<UserProfile>) => {
    setLoading(true);
    try {
      const response = await api.put<UserProfile>('/admin/profile', newProfile);
      setProfile(response);
      setError(null);
    } catch (err: unknown) {
      if (err instanceof Error) {
        setError(err.message);
        throw err;
      }
      setError('An unknown error occurred');
      throw new Error('An unknown error occurred');
    } finally {
      setLoading(false);
    }
  };

  return { 
    settings, 
    profile, 
    loading, 
    error,
    updateSettings, 
    updateProfile,
    refetch: { fetchSettings, fetchProfile }
  };
};

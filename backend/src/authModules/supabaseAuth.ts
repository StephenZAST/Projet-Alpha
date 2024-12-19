import { supabase } from '../config/supabase';
import { UserCredentials } from '../types/types';

export const registerWithSupabase = async (credentials: UserCredentials) => {
  const { email, password, user_metadata } = credentials;

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: user_metadata
    }
  });

  if (error) {
    throw error;
  }

  return data;
};

export const loginWithSupabase = async (credentials: UserCredentials) => {
  const { email, password } = credentials;

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    throw error;
  }

  return data;
};

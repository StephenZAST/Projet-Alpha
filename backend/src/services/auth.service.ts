import supabase from '../config/database';
import { AuthResponse, User } from '../models/types';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import * as jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET;
const blacklistedTokens = new Set<string>();

export class AuthService {
  static async register(email: string, password: string, firstName: string, lastName: string, phone?: string, affiliateCode?: string, role: string = 'CLIENT'): Promise<User> {
    const hashedPassword = await bcrypt.hash(password, 10);

    // Créer l'objet pour Supabase (snake_case)
    const dbUser = {
      id: uuidv4(),
      email,
      password: hashedPassword,
      first_name: firstName,
      last_name: lastName,
      phone,
      role,
      referral_code: affiliateCode,
      created_at: new Date(),
      updated_at: new Date()
    };

    const { data, error } = await supabase
      .from('users')
      .insert([dbUser])
      .select()
      .single();

    if (error) {
      console.error('Register error:', error);
      throw error;
    }

    // Transformer la réponse en format User (camelCase)
    const user: User = {
      id: data.id,
      email: data.email,
      password: data.password,
      firstName: data.first_name,
      lastName: data.last_name,
      phone: data.phone,
      role: data.role,
      referralCode: data.referral_code,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at)
    };

    return user;
  }

  static async login(email: string, password: string): Promise<{ user: User, token: string }> {
    const { data: users, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email);

    if (error) throw error;

    if (!users || users.length === 0) {
      throw new Error('User not found');
    }

    if (users.length > 1) {
      console.error('Multiple users found for the same email:', users);
      throw new Error('Multiple users found for the same email');
    }

    const user = users[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    // Modification du payload JWT pour inclure l'id comme 'id' au lieu de 'userId'
    const token = jwt.sign(
      { 
        id: user.id,  // Changé de userId à id
        role: user.role 
      }, 
      process.env.JWT_SECRET!, 
      { expiresIn: '1h' }
    );

    return { user, token };
  }

  static async invalidateToken(token: string): Promise<void> {
    blacklistedTokens.add(token);
  }

  static isTokenBlacklisted(token: string): boolean {
    return blacklistedTokens.has(token);
  }

  static async getCurrentUser(userId: string): Promise<User> {
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) throw error;

    return user;
  }

  static async createAffiliate(userId: string): Promise<User> {
    const { data: user, error } = await supabase
      .from('users')
      .update({ role: 'AFFILIATE' })
      .eq('id', userId)
      .select()
      .single();

    if (error) throw error;

    return user;
  }

  static async getAllUsers(): Promise<User[]> {
    const { data, error } = await supabase
      .from('users')
      .select('*');

    if (error) throw error;

    return data;
  }

  static async createAdmin(email: string, password: string, firstName: string, lastName: string, phone?: string): Promise<User> {
    const hashedPassword = await bcrypt.hash(password, 10);

    const dbUser = {
      id: uuidv4(),
      email,
      password: hashedPassword,
      first_name: firstName,
      last_name: lastName,
      phone,
      role: 'ADMIN',
      created_at: new Date(),
      updated_at: new Date()
    };

    const { data, error } = await supabase
      .from('users')
      .insert([dbUser])
      .select()
      .single();

    if (error) throw error;

    // Transformer la réponse
    return {
      id: data.id,
      email: data.email,
      password: data.password,
      firstName: data.first_name,
      lastName: data.last_name,
      phone: data.phone,
      role: data.role,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at)
    } as User;
  }

  static async updateProfile(userId: string, email: string, firstName: string, lastName: string, phone?: string): Promise<User> {
    const { data, error } = await supabase
      .from('users')
      .update({ email, first_name: firstName, last_name: lastName, phone, updated_at: new Date() })  // Changed from firstName, lastName, updatedAt
      .eq('id', userId)
      .select()
      .single();

    if (error) throw error;

    return {
      ...data,
      firstName: data.first_name,
      lastName: data.last_name,
      updatedAt: new Date(data.updated_at)
    } as User;
  }

  static async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<User> {
    const { data: user, error: selectError } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (selectError) throw selectError;

    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid current password');
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);

    const { data, error: updateError } = await supabase
      .from('users')
      .update({ password: hashedNewPassword, updated_at: new Date() })  // Changed from updatedAt
      .eq('id', userId)
      .select()
      .single();

  if (updateError) throw updateError;

    return {
      ...data,
      updatedAt: new Date(data.updated_at)
    } as User;
  }

  static async deleteAccount(userId: string): Promise<void> {
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('id', userId);

    if (error) throw error;
  }

  static async deleteUser(targetUserId: string, userId: string): Promise<void> {
    const { data: user, error: selectError } = await supabase
      .from('users')
      .select('*')
      .eq('id', targetUserId)
      .single();

    if (selectError) throw selectError;

    if (user.role === 'SUPER_ADMIN' && userId !== targetUserId) {
      throw new Error('Super Admin can only delete their own account');
    }

    const { error: deleteError } = await supabase
      .from('users')
      .delete()
      .eq('id', targetUserId);

    if (deleteError) throw deleteError;
  }

  static async updateUser(targetUserId: string, email: string, firstName: string, lastName: string, phone?: string, role?: string): Promise<User> {
    const { data: user, error: selectError } = await supabase
      .from('users')
      .select('*')
      .eq('id', targetUserId)
      .single();

    if (selectError) throw selectError;

    const { data, error: updateError } = await supabase
      .from('users')
      .update({ email, first_name: firstName, last_name: lastName, phone, role, updated_at: new Date() })  // Changed from firstName, lastName, updatedAt
      .eq('id', targetUserId)
      .select()
      .single();

    if (updateError) throw updateError;

    return {
      ...data,
      firstName: data.first_name,
      lastName: data.last_name,
      updatedAt: new Date(data.updated_at)
    } as User;
  }

  static async registerAffiliate(email: string, password: string, firstName: string, lastName: string, phone?: string, parentAffiliateCode?: string): Promise<AuthResponse> {
    try {
      // Démarrer une transaction
      const { data: user, error: userError } = await supabase
        .from('users')
        .insert([{
          id: uuidv4(),
          email,
          password: await bcrypt.hash(password, 10),
          first_name: firstName,
          last_name: lastName,
          phone,
          role: 'AFFILIATE',
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (userError) {
        if (userError.message.includes('duplicate key')) {
          throw new Error('Email already exists');
        }
        throw userError;
      }

      // Générer un code affilié unique
      const affiliateCode = Math.random().toString(36).substr(2, 9).toUpperCase();

      // Créer le profil affilié
      const { data: affiliateProfile, error: affiliateError } = await supabase
        .from('affiliate_profiles')
        .insert([{
          user_id: user.id,
          affiliate_code: affiliateCode,
          parent_affiliate_id: null, // On gèrera le parent plus tard si nécessaire
          commission_balance: 0,
          total_earned: 0
        }])
        .select()
        .single();

      if (affiliateError) {
        // Si erreur lors de la création du profil, supprimer l'utilisateur
        await supabase.from('users').delete().eq('id', user.id);
        throw affiliateError;
      }

      // Générer le token
      const token = jwt.sign(
        { id: user.id, role: user.role },
        JWT_SECRET!,
        { expiresIn: '1h' }
      );

      return {
        user: {
          ...user,
          firstName: user.first_name,
          lastName: user.last_name,
          createdAt: new Date(user.created_at),
          updatedAt: new Date(user.updated_at)
        },
        token,
        affiliateProfile
      };
    } catch (error: any) {
      throw error;
    }
  }

  static async resetPassword(email: string): Promise<void> {
    const { error } = await supabase.auth.resetPasswordForEmail(email);
    if (error) {
      console.error('Error resetting password:', error);
      throw new Error('Failed to send reset password email.');
    }
  }
}

import supabase from '../config/database';
import { AuthResponse, User, ResetCode } from '../models/types';
import bcrypt from 'bcryptjs';
import { sendEmail } from './email.service';
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
    try {
        console.log('Starting login process for:', email);

        // 1. Récupérer l'utilisateur
        const { data: user, error: userError } = await supabase
            .from('users')
            .select('*')
            .eq('email', email)
            .single();

        if (userError || !user) {
            console.error('User not found:', email);
            throw new Error('User not found');
        }

        // 2. Vérifier le mot de passe
        console.log('Input password:', password);
        console.log('Stored hash:', user.password);
        
        const isValid = await bcrypt.compare(password, user.password);
        
        console.log('Password validation result:', {
            isValid,
            email,
            inputPassword: password,
            storedHash: user.password
        });

        if (!isValid) {
            throw new Error('Invalid credentials');
        }

        // 3. Générer le token
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET!,
            { expiresIn: '24h' }
        );

        return {
            user: {
                ...user,
                firstName: user.first_name,
                lastName: user.last_name,
                createdAt: new Date(user.created_at),
                updatedAt: new Date(user.updated_at)
            },
            token
        };
    } catch (error) {
        console.error('Login failed:', error);
        throw error;
    }
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
    try {
        // 1. Vérifier si l'utilisateur existe et obtenir son ID
        const { data: user, error: userError } = await supabase
            .from('users')
            .select('id, email')
            .eq('email', email)
            .single();

        if (userError || !user) {
            console.error('User check error:', userError);
            throw new Error('User not found');
        }

        // 2. Générer un nouveau code
        const code = this.generateVerificationCode();
        const expirationTime = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

        // 3. Insérer le code dans la base de données avec user_id
        const { error: resetCodeError } = await supabase
            .from('reset_codes')
            .insert([{
                user_id: user.id,
                email: email,
                code: code,
                expires_at: expirationTime,
                used: false,
                created_at: new Date(),
                updated_at: new Date()
            }]);

        if (resetCodeError) {
            console.error('Reset code storage error:', resetCodeError);
            throw new Error('Failed to store reset code');
        }

        // 4. Envoyer l'email
        try {
            await sendEmail(email, code);
            console.log('Reset code email sent successfully to:', email);
        } catch (emailError) {
            console.error('Email sending error:', emailError);
            throw new Error('Failed to send reset code email');
        }

    } catch (error) {
        console.error('Reset password process error:', error);
        throw error;
    }
}

  static generateVerificationCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString(); // Code à 6 chiffres
  }

  static async storeVerificationCode(email: string, code: string) {
    const expirationTime = new Date();
    expirationTime.setMinutes(expirationTime.getMinutes() + 15); // Code valide 15 minutes

    const { data, error } = await supabase
      .from('reset_codes')
      .insert({
        email,
        code,
        expires_at: expirationTime,
        used: false
      });

    return { data, error };
  }

  static async sendVerificationEmail(email: string, code: string) {
    try {
      await sendEmail(email, code);
      return true;
    } catch (error) {
      console.error('Error sending email:', error);
      throw new Error('Failed to send verification email');
    }
  }

  static async validateResetCode(email: string, code: string): Promise<boolean> {
    try {
        console.log('Validating reset code:', { email, code });
        
        const { data, error } = await supabase
            .from('reset_codes')
            .select('*')
            .match({ email, code, used: false })
            .gt('expires_at', new Date().toISOString())
            .order('created_at', { ascending: false })
            .limit(1);
        
        if (error) {
            console.error('Database error during validation:', error);
            return false;
        }

        console.log('Found reset codes:', data);
        
        // Vérifier si nous avons trouvé un code valide
        if (!data || data.length === 0) {
            console.log('No valid reset code found');
            return false;
        }

        return true;
    } catch (error) {
        console.error('Reset code validation error:', error);
        return false;
    }
}

  static async verifyCodeAndResetPassword(email: string, code: string, newPassword: string): Promise<void> {
    try {
        console.log('Starting password reset for:', email);

        // 1. Vérifier le code de réinitialisation
        const { data: resetCodes, error: codeError } = await supabase
            .from('reset_codes')
            .select('*')
            .eq('email', email)
            .eq('code', code)
            .eq('used', false)
            .gt('expires_at', new Date().toISOString())
            .single();

        if (codeError || !resetCodes) {
            console.error('Reset code validation failed:', codeError);
            throw new Error('Invalid or expired reset code');
        }

        // 2. Hasher le nouveau mot de passe
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        console.log('New password hash:', hashedPassword);

        // 3. Mettre à jour le mot de passe dans la base de données
        const { error: updateError } = await supabase
            .from('users')
            .update({
                password: hashedPassword,
                updated_at: new Date().toISOString()
            })
            .eq('email', email);

        if (updateError) {
            console.error('Password update failed:', updateError);
            throw new Error('Failed to update password');
        }

        // 4. Vérifier immédiatement que le nouveau mot de passe fonctionne
        const testVerification = await bcrypt.compare(newPassword, hashedPassword);
        console.log('Password verification test:', testVerification);

        if (!testVerification) {
            throw new Error('Password verification failed');
        }

        // 5. Marquer le code comme utilisé
        await supabase
            .from('reset_codes')
            .update({
                used: true,
                updated_at: new Date().toISOString()
            })
            .eq('id', resetCodes.id);

        console.log('Reset code marked as used');
        console.log('Password reset completed successfully');

    } catch (error) {
        console.error('Password reset failed:', error);
        throw error;
    }
}

}

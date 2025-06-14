import { PrismaClient, user_role, Prisma } from '@prisma/client'; // Ajout de l'import Prisma
import { AuthResponse, User, ResetCode, UserListResponse, UserStats, UserFilters, UserActivityLog } from '../models/types';
import bcrypt from 'bcryptjs';
import { sendEmail } from './email.service';
import { v4 as uuidv4 } from 'uuid'; 
import * as jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET;
const blacklistedTokens = new Set<string>();
const prisma = new PrismaClient();

export class AuthService {
  static async register(
    email: string,
    password: string,
    firstName: string,
    lastName: string,
    phone?: string,
    affiliateCode?: string,
    role: string = 'CLIENT'
  ): Promise<User> {
    const existingUser = await prisma.users.findFirst({
        where: { email }
    });

    if (existingUser) {
        throw new Error('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUserId = uuidv4();

    try {
        const user = await prisma.users.create({
            data: {
                id: newUserId,
                email,
                password: hashedPassword,
                first_name: firstName,
                last_name: lastName,
                phone,
                role: role as user_role,
                referral_code: affiliateCode,
                created_at: new Date(),
                updated_at: new Date(),
                loyalty_points: {
                    create: {
                        id: uuidv4(),
                        pointsBalance: 0,
                        totalEarned: 0,
                        createdAt: new Date(),
                        updatedAt: new Date()
                    }
                },
                notification_preferences: {
                    create: {
                        id: uuidv4(),
                        email: true,
                        push: true,
                        sms: false,
                        order_updates: true,
                        promotions: true,
                        payments: true,
                        loyalty: true,
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                }
            }
        });

        // Mapper le résultat
        return {
            id: user.id,
            email: user.email,
            password: user.password,
            firstName: user.first_name,
            lastName: user.last_name,
            phone: user.phone || undefined,
            role: user.role || 'CLIENT',
            referralCode: user.referral_code || undefined,
            createdAt: user.created_at || new Date(),
            updatedAt: user.updated_at || new Date()
        };
    } catch (error) {
        console.error('Register error:', error);
        if (error instanceof Prisma.PrismaClientKnownRequestError) {
            console.error('Prisma error details:', {
                code: error.code,
                meta: error.meta,
                message: error.message
            });
        }
        throw error;
    }
  }

  static async login(email: string, password: string): Promise<{ user: User; token: string }> {
    const user = await prisma.users.findFirst({
      where: { email }
    });

    if (!user) {
      throw new Error('Invalid email or password');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid email or password');
    }

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET!, {
      expiresIn: '168h',
    });

    return { 
      user: {
      id: user.id,
      email: user.email,
      password: user.password,
      firstName: user.first_name,
      lastName: user.last_name,
      phone: user.phone || undefined,
      role: user.role || 'CLIENT', 
      referralCode: user.referral_code || undefined,
      createdAt: user.created_at || new Date(),
      updatedAt: user.updated_at || new Date()
      }, 
      token 
    };
  }

  static async invalidateToken(token: string): Promise<void> {
    blacklistedTokens.add(token);
  }

  static isTokenBlacklisted(token: string): boolean {
    return blacklistedTokens.has(token);
  }

  static async getCurrentUser(userId: string) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
      include: {
        addresses: true
      }
    });

    if (!user) throw new Error('User not found');
    return user;
  }

  static async createAffiliate(userId: string): Promise<User> {
    const user = await prisma.users.update({
      where: { id: userId },
      data: { role: 'AFFILIATE' }
    });

    const affiliateCode = Math.random().toString(36).substr(2, 9).toUpperCase();

    try {
      await prisma.affiliate_profiles.create({
        data: {
          user_id: userId,
          affiliate_code: affiliateCode,
          parent_affiliate_id: null,
          commission_balance: 0,
          total_earned: 0,
          monthly_earnings: 0,
          total_referrals: 0,
          commission_rate: 10.00,
          status: 'PENDING',
          is_active: true,
          created_at: new Date(),
          updated_at: new Date()
        }
      });
    } catch (error) {
      await prisma.users.update({
        where: { id: userId },
        data: { role: 'CLIENT' }
      });
      throw error;
    }

    return {
      id: user.id,
      email: user.email,
      password: user.password,
      firstName: user.first_name,
      lastName: user.last_name,
      phone: user.phone || undefined,
      role: user.role || 'CLIENT',
      referralCode: user.referral_code || undefined,
      createdAt: user.created_at || new Date(),
      updatedAt: user.updated_at || new Date()
    };
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

    const data = await prisma.users.create({
      data: {
      id: dbUser.id,
      email: dbUser.email,
      password: dbUser.password,
      first_name: dbUser.first_name,
      last_name: dbUser.last_name,
      phone: dbUser.phone,
      role: dbUser.role as any,
      created_at: dbUser.created_at,
      updated_at: dbUser.updated_at
      }
    });

    return {
      id: data.id,
      email: data.email,
      password: data.password,
      firstName: data.first_name,
      lastName: data.last_name,
      phone: data.phone,
      role: data.role,
      createdAt: data.created_at,
      updatedAt: data.updated_at
    } as User;
  }

  static async updateProfile(userId: string, email: string, firstName: string, lastName: string, phone?: string): Promise<User> {
    const data = await prisma.users.update({
      where: { id: userId },
      data: { email, first_name: firstName, last_name: lastName, phone, updated_at: new Date() }
    });

    return {
      id: data.id,
      email: data.email,
      password: data.password,
      firstName: data.first_name,
      lastName: data.last_name,
      phone: data.phone || undefined,
      role: data.role || 'CLIENT',
      referralCode: data.referral_code || undefined,
      createdAt: data.created_at || new Date(),
      updatedAt: data.updated_at || new Date()
    } as User;
  }

  static async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<User> {
    const user = await prisma.users.findUnique({
      where: { id: userId }
    });

    if (!user) throw new Error('User not found');

    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid current password');
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    const data = await prisma.users.update({
      where: { id: userId },
      data: { password: hashedNewPassword, updated_at: new Date() }
    });

    return {
      id: data.id,
      email: data.email,
      password: data.password,
      firstName: data.first_name,
      lastName: data.last_name,
      phone: data.phone || undefined,
      role: data.role || 'CLIENT',
      referralCode: data.referral_code || undefined,
      createdAt: data.created_at || new Date(),
      updatedAt: data.updated_at || new Date()
    };
  }

  static async deleteAccount(userId: string): Promise<void> {
    await prisma.users.delete({
      where: { id: userId }
    });
  }

  static async deleteUser(targetUserId: string, userId: string): Promise<void> {
    const user = await prisma.users.findUnique({
      where: { id: targetUserId }
    });

    if (!user) throw new Error('User not found');

    if (user.role === 'SUPER_ADMIN' && userId !== targetUserId) {
      throw new Error('Super Admin can only delete their own account');
    }

    await prisma.users.delete({
      where: { id: targetUserId }
    });
  }

  static async updateUser(targetUserId: string, email: string, firstName: string, lastName: string, phone?: string, role?: string): Promise<User> {
    const user = await prisma.users.findUnique({
      where: { id: targetUserId }
    });

    if (!user) throw new Error('User not found');

    const data = await prisma.users.update({
      where: { id: targetUserId },
      data: { email, first_name: firstName, last_name: lastName, phone, role: role as user_role, updated_at: new Date() }
    });

    return {
      id: data.id,
      email: data.email,
      password: data.password,
      firstName: data.first_name,
      lastName: data.last_name,
      phone: data.phone || undefined,
      role: data.role || 'CLIENT',
      referralCode: data.referral_code || undefined,
      createdAt: data.created_at || new Date(),
      updatedAt: data.updated_at || new Date()
    } as User;
  }

  static async registerAffiliate(email: string, password: string, firstName: string, lastName: string, phone?: string, parentAffiliateCode?: string): Promise<AuthResponse> {
    try {
      const user = await prisma.users.create({
        data: {
          id: uuidv4(),
          email,
          password: await bcrypt.hash(password, 10),
          first_name: firstName,
          last_name: lastName,
          phone,
          role: 'AFFILIATE',
          created_at: new Date(),
          updated_at: new Date()
        }
      });

      const affiliateCode = Math.random().toString(36).substr(2, 9).toUpperCase();

      const affiliateProfile = await prisma.affiliate_profiles.create({
        data: {
          user_id: user.id,
          affiliate_code: affiliateCode,
          parent_affiliate_id: null,
          commission_balance: 0,
          total_earned: 0
        }
      });

      const token = jwt.sign(
        { id: user.id, role: user.role },
        JWT_SECRET!,
        { expiresIn: '168h' }
      );

      return {
        user: {
          id: user.id,
          email: user.email,
          password: user.password,
          firstName: user.first_name,
          lastName: user.last_name,
          phone: user.phone || undefined,
          role: user.role || 'CLIENT', 
          referralCode: user.referral_code || undefined,
          createdAt: user.created_at || new Date(),
          updatedAt: user.updated_at || new Date()
        },
        token,
        affiliateProfile: {
          id: affiliateProfile.id,
          userId: affiliateProfile.user_id,
          affiliateCode: affiliateProfile.affiliate_code,
          commission_rate: Number(affiliateProfile.commission_rate || 10),
          commissionBalance: Number(affiliateProfile.commission_balance || 0),
          totalEarned: Number(affiliateProfile.total_earned || 0),
          status: affiliateProfile.status || 'PENDING',
          isActive: affiliateProfile.is_active || true,
          totalReferrals: affiliateProfile.total_referrals || 0,
          monthlyEarnings: Number(affiliateProfile.monthly_earnings || 0),
          levelId: affiliateProfile.level_id ?? undefined,
          createdAt: affiliateProfile.created_at || new Date(),
          updatedAt: affiliateProfile.updated_at || new Date()
        }
      };
    } catch (error: any) {
      throw error;
    }
  }

  static async resetPassword(email: string): Promise<void> {
    try {
      const user = await prisma.users.findFirst({
        where: { email }
      });

      if (!user) {
        throw new Error('User not found');
      }

      const code = this.generateVerificationCode();
      const expirationTime = new Date(Date.now() + 15 * 60 * 1000);

      await prisma.reset_codes.create({
        data: {
          user_id: user.id,
          email: email,
          code: code,
          expires_at: expirationTime,
          used: false,
          created_at: new Date(),
          updated_at: new Date()
        }
      });

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
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  static async storeVerificationCode(email: string, code: string) {
    const expirationTime = new Date();
    expirationTime.setMinutes(expirationTime.getMinutes() + 15);

    const user = await prisma.users.findFirst({
      where: { email }
    });

    if (!user) {
      throw new Error('User not found');
    }

    const data = await prisma.reset_codes.create({
      data: {
      user_id: user.id,
      email,
      code,
      expires_at: expirationTime,
      used: false
      }
    });

    return { data };
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
      const resetCode = await prisma.reset_codes.findFirst({
        where: {
          email,
          code,
          used: false,
          expires_at: {
            gt: new Date()
          }
        },
        orderBy: {
          created_at: 'desc'
        }
      });

      if (!resetCode) {
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
      const resetCode = await prisma.reset_codes.findFirst({
        where: {
          email,
          code,
          used: false,
          expires_at: {
            gt: new Date()
          }
        }
      });

      if (!resetCode) {
        throw new Error('Invalid or expired reset code');
      }

      const hashedPassword = await bcrypt.hash(newPassword, 10);

      await prisma.users.findFirst({
        where: { email }
      }).then(user => {
        if (!user) throw new Error('User not found');
        return prisma.users.update({
          where: { id: user.id },
          data: {
        password: hashedPassword,
        updated_at: new Date()
          }
        });
      });

      const testVerification = await bcrypt.compare(newPassword, hashedPassword);

      if (!testVerification) {
        throw new Error('Password verification failed');
      }

      await prisma.reset_codes.update({
        where: { id: resetCode.id },
        data: {
          used: true,
          updated_at: new Date()
        }
      });

      console.log('Password reset completed successfully');
    } catch (error) {
      console.error('Password reset failed:', error);
      throw error;
    }
  }

  static async getAllUsers({
    page = 1,
    limit = 10,
    filters = {}
  }: {
    page?: number;
    limit?: number;
    filters?: UserFilters;
  } = {}): Promise<UserListResponse> {
    try {
      const offset = (page - 1) * limit;
      let query = prisma.users.findMany({
        skip: offset,
        take: limit,
        orderBy: {
          created_at: 'desc'
        }
      });

      if (filters.role) {
        query = prisma.users.findMany({
          where: {
            role: filters.role.toUpperCase() as user_role
          }
        });
      }

      if (filters.searchQuery) {
        query = prisma.users.findMany({
          where: {
            OR: [
              { first_name: { contains: filters.searchQuery, mode: 'insensitive' } },
              { last_name: { contains: filters.searchQuery, mode: 'insensitive' } },
              { email: { contains: filters.searchQuery, mode: 'insensitive' } }
            ]
          }
        });
      }

      if (filters.startDate) {
        query = prisma.users.findMany({
          where: {
            created_at: {
              gte: filters.startDate
            }
          }
        });
      }

      if (filters.endDate) {
        query = prisma.users.findMany({
          where: {
            created_at: {
              lte: filters.endDate
            }
          }
        });
      }

      const data = await query;
      const count = await prisma.users.count();

      return {
        data: data.map(user => ({
          id: user.id,
          email: user.email,
          firstName: user.first_name,
          lastName: user.last_name,
          phone: user.phone,
          role: user.role,
          password: user.password,
          createdAt: user.created_at,
          updatedAt: user.updated_at
        })) as User[],
        pagination: {
          total: count,
          page,
          limit,
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      console.error('Error in getAllUsers:', error);
      throw error;
    }
  }

  static async getUserStats(): Promise<UserStats> {
    try {
      const rawStats = await prisma.users.findMany({
        select: {
          role: true
        }
      });

      const stats: UserStats = {
        total: 0,
        clientCount: 0,
        affiliateCount: 0,
        adminCount: 0,
        activeToday: 0,
        newThisWeek: 0,
        byRole: {}
      };

      rawStats.forEach((user: any) => {
        stats.total++;
        const role = user.role.toLowerCase();
        stats.byRole[role] = (stats.byRole[role] || 0) + 1;

        switch (user.role) {
          case 'CLIENT':
            stats.clientCount++;
            break;
          case 'AFFILIATE':
            stats.affiliateCount++;
            break;
          case 'ADMIN':
          case 'SUPER_ADMIN':
            stats.adminCount++;
            break;
        }
      });

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const weekAgo = new Date(today);
      weekAgo.setDate(weekAgo.getDate() - 7);

      const activeCount = await prisma.users.count({
        where: {
          created_at: {
        gte: today
          }
        }
      });

      const newUsersCount = await prisma.users.count({
        where: {
          created_at: {
            gte: weekAgo
          }
        }
      });

      stats.activeToday = activeCount;
      stats.newThisWeek = newUsersCount;

      return stats;
    } catch (error) {
      console.error('Error in getUserStats:', error);
      throw error;
    }
  }

  static async getUserNotifications(userId: string) {
    const data = await prisma.notifications.findMany({
      where: { user_id: userId },
      orderBy: {
        created_at: 'desc'
      }
    });

    return data;
  }

  static async updateNotificationPreferences(userId: string, preferences: any) {
    const existingPrefs = await prisma.notification_preferences.findFirst({
      where: { user_id: userId }
    });

    await prisma.notification_preferences.upsert({
      where: { id: existingPrefs?.id ?? uuidv4() },
      update: {
      email: preferences.email,
      push: preferences.push,
      sms: preferences.sms,
      order_updates: preferences.orderUpdates,
      promotions: preferences.promotions, 
      payments: preferences.payments,
      loyalty: preferences.loyalty,
      updated_at: new Date()
      },
      create: {
      id: uuidv4(),
      user_id: userId,
      email: preferences.email ?? true,
      push: preferences.push ?? true,
      sms: preferences.sms ?? false,
      order_updates: preferences.orderUpdates ?? true,
      promotions: preferences.promotions ?? true,
      payments: preferences.payments ?? true,  
      loyalty: preferences.loyalty ?? true,
      updated_at: new Date()
      }
    });

    return true;
  }

  static async getUserAddresses(userId: string) {
    const data = await prisma.addresses.findMany({
      where: { user_id: userId }
    });

    return data;
  }

  static async getUserLoyaltyPoints(userId: string) {
    const data = await prisma.loyalty_points.findUnique({
      where: { user_id: userId }
    });

    return data;
  }

  static async logUserActivity(activity: Omit<UserActivityLog, 'id' | 'createdAt'>): Promise<void> {
    try {
        // Utilisation de $executeRaw pour une insertion directe
        await prisma.$executeRaw`
            INSERT INTO user_activity_logs (
                id, 
                user_id, 
                action, 
                details, 
                ip_address, 
                user_agent, 
                created_at
            ) VALUES (
                ${uuidv4()}, 
                ${activity.userId}, 
                ${activity.action}, 
                ${activity.details || {}}, 
                ${activity.ipAddress}, 
                ${activity.userAgent}, 
                ${new Date()}
            )
        `;
    } catch (error) {
        console.error('Error logging user activity:', error);
        // Log l'erreur mais ne la propage pas pour ne pas interrompre le flux principal
        console.log('Activity details:', activity);
    }
  }

  // Nouvelle méthode spécifique pour la création d'utilisateur par l'admin
  static async createUserByAdmin(
    adminId: string,
    userData: {
      email: string;
      password: string;
      first_name: string;
      last_name: string;
      phone?: string;
      role?: string;
    }
  ): Promise<any> {
    try {
      // Vérifier que l'admin existe
      const admin = await prisma.users.findUnique({
        where: { id: adminId }
      });

      if (!admin || (admin.role !== 'ADMIN' && admin.role !== 'SUPER_ADMIN')) {
        throw new Error('Unauthorized admin access');
      }

      // Vérifier si l'email existe déjà
      const existingUser = await prisma.users.findFirst({
        where: { email: userData.email }
      });

      if (existingUser) {
        throw new Error('Email already exists');
      }

      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash(userData.password, 10);

      // Créer l'utilisateur avec transaction
      return await prisma.$transaction(async (tx) => {
        // 1. Créer l'utilisateur
        const user = await tx.users.create({
          data: {
            id: uuidv4(),
            email: userData.email,
            password: hashedPassword,
            first_name: userData.first_name,
            last_name: userData.last_name,
            phone: userData.phone,
            role: 'CLIENT', // Forcer le rôle CLIENT pour cette méthode
            created_at: new Date(),
            updated_at: new Date()
          }
        });

        // 2. Initialiser les points de fidélité
        await tx.loyalty_points.create({
          data: {
            id: uuidv4(),
            user_id: user.id,
            pointsBalance: 0,
            totalEarned: 0,
            createdAt: new Date(),
            updatedAt: new Date()
          }
        });

        // 3. Créer les préférences de notification
        await tx.notification_preferences.create({
          data: {
            id: uuidv4(),
            user_id: user.id,
            email: true,
            push: true,
            sms: false,
            order_updates: true,
            promotions: true,
            payments: true,
            loyalty: true,
            created_at: new Date(),
            updated_at: new Date()
          }
        });

        return user;
      });
    } catch (error) {
      console.error('[AuthService] Create user by admin error:', error);
      throw error;
    }
  }
}

import supabase from '../../config/supabase';
import { User, UserProfile } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';

const usersTable = 'users';

export async function getUserProfile(userId: string): Promise<UserProfile> {
  try {
    const { data, error } = await supabase.from(usersTable).select('*').eq('id', userId).single();

    if (error) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    return {
      ...data.profile,
      lastUpdated: data.updatedAt
    };
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
  }
}

export async function getUserById(userId: string): Promise<User | null> {
  const { data, error } = await supabase.from(usersTable).select('*').eq('id', userId).single();

  if (error) {
    return null;
  }

  return {
    ...data
  };
}

export async function getUsers({ page = 1, limit = 10, search = '' }): Promise<{ users: User[], total: number, page: number, totalPages: number }> {
  try {
    const { count, error: countError } = await supabase
      .from(usersTable)
      .select('*', { count: 'exact' });

    if (countError) {
      throw new AppError(500, 'Failed to fetch user count', errorCodes.DATABASE_ERROR);
    }

    const total = count;
    const totalPages = Math.ceil(total / limit);

    let { data, error } = await supabase
      .from(usersTable)
      .select('*')
      .order('createdAt', { ascending: false })
      .range((page - 1) * limit, ((page - 1) * limit) + limit - 1);

    if (search) {
      data = data.filter((user: { profile: { displayName: string; }; }) => user.profile.displayName?.toLowerCase().includes(search.toLowerCase()));
    }

    if (error) {
      throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
    }

    return {
      users: data,
      total,
      page,
      totalPages
    };
  } catch (error) {
    throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
  }
}

export async function getUserByEmail(email: string): Promise<User | null> {
  const { data, error } = await supabase
    .from(usersTable)
    .select('*')
    .eq('profile.email', email)
    .single();

  if (error) {
    return null;
  }

  return {
    ...data
  };
}

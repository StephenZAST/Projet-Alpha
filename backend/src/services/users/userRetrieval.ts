import supabase from '../../config/supabase';
import { User, UserProfile } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';

const usersTable = 'users';

export async function getUserProfile(userId: string): Promise<UserProfile | null> {
  try {
    const { data, error } = await supabase.from(usersTable).select('profile').eq('id', userId).single();

    if (error) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    if (!data || !data.profile) {
      return null;
    }

    return data.profile;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
  }
}

export async function getUserById(userId: string): Promise<Omit<User, 'password'> | null> {
  const { data, error } = await supabase.from(usersTable).select('*').eq('id', userId).single();

  if (error) {
    return null;
  }

  if (!data) {
    return null;
  }

  return {
    id: data.id,
    uid: data.uid,
    firstName: data.firstName,
    lastName: data.lastName,
    email: data.email,
    phone: data.phone,
    role: data.role,
    profile: data.profile,
    status: data.status,
    address: data.address,
    creationMethod: data.creationMethod,
    createdAt: data.createdAt,
    updatedAt: data.updatedAt,
    fcmToken: data.fcmToken,
  };
}

export async function getUsers({ page = 1, limit = 10, search = '' }): Promise<{ users: (Omit<User, 'password'>)[]; total: number; page: number; totalPages: number }> {
  try {
    const { data: countData, count, error: countError } = await supabase
      .from(usersTable)
      .select('*', { count: 'exact', head: true });

    if (countError) {
      throw new AppError(500, 'Failed to fetch user count', errorCodes.DATABASE_ERROR);
    }

    if (count === null) {
      throw new AppError(500, 'Failed to fetch user count', errorCodes.DATABASE_ERROR);
    }

    const total = count;
    const totalPages = Math.ceil(total / limit);

    let { data, error } = await supabase
      .from(usersTable)
      .select('*')
      .order('createdAt', { ascending: false })
      .range((page - 1) * limit, ((page - 1) * limit) + limit - 1);

    if (error) {
      throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
    }

    if (search) {
      data = data.filter(user =>
        user.firstName?.toLowerCase().includes(search.toLowerCase()) ||
        user.lastName?.toLowerCase().includes(search.toLowerCase())
      );
    }

    const users: (Omit<User, 'password'>)[] = data.map(user => ({
      id: user.id,
      uid: user.uid,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      profile: user.profile,
      status: user.status,
      address: user.address,
      creationMethod: user.creationMethod,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      fcmToken: user.fcmToken,
    }));

    return {
      users,
      total,
      page,
      totalPages
    };
  } catch (error) {
    throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
  }
}

export async function getUserByEmail(email: string): Promise<Omit<User, 'password'> | null> {
  const { data, error } = await supabase
    .from(usersTable)
    .select('*')
    .eq('email', email)
    .single();

  if (error) {
    return null;
  }

  if (!data) {
    return null;
  }

  if (data.id === null) {
    throw new AppError(500, 'User ID is null', errorCodes.DATABASE_ERROR);
  }

  return {
    id: data.id,
    uid: data.uid,
    firstName: data.firstName,
    lastName: data.lastName,
    email: data.email,
    phone: data.phone,
    role: data.role,
    profile: data.profile,
    status: data.status,
    address: data.address,
    creationMethod: data.creationMethod,
    createdAt: data.createdAt,
    updatedAt: data.updatedAt,
    fcmToken: data.fcmToken,
  };
}

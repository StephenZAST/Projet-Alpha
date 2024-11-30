import { AppError } from '../utils/errors';
import bcrypt from 'bcrypt';

interface User {
  uid: string;
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  role: string;
}

class AuthService {
  private users: Map<string, User> = new Map();
  private masterAdminCreated: boolean = false;

  async createMasterAdmin(userData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phoneNumber: string;
  }): Promise<User> {
    if (this.masterAdminCreated) {
      throw new AppError(400, 'Master admin already exists', 'ADMIN_EXISTS');
    }

    const { email, password, firstName, lastName, phoneNumber } = userData;

    // Validate data
    if (!email || !password) {
      throw new AppError(400, 'Email and password are required', 'INVALID_DATA');
    }

    // Check if email already exists
    if (Array.from(this.users.values()).some(user => user.email === email)) {
      throw new AppError(400, 'Email already exists', 'EMAIL_EXISTS');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user: User = {
      uid: Date.now().toString(),
      email,
      password: hashedPassword,
      firstName,
      lastName,
      phoneNumber,
      role: 'master_admin'
    };

    this.users.set(user.uid, user);
    this.masterAdminCreated = true;

    // Return user without password
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  async login(email: string, password: string): Promise<User> {
    const user = Array.from(this.users.values()).find(u => u.email === email);

    if (!user) {
      throw new AppError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new AppError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
    }

    // Return user without password
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  getUser(uid: string): User | null {
    const user = this.users.get(uid);
    if (!user) return null;
    
    // Return user without password
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }
}

export const authService = new AuthService();

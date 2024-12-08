import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { AppError, errorCodes } from './errors';

// Number of salt rounds for bcrypt
const SALT_ROUNDS = 12;

interface TokenPayload {
  uid: string;
  email?: string | null;
  role?: string;
}

/**
 * Hash a password using bcrypt
 * @param password Plain text password to hash
 * @returns Promise resolving to hashed password
 */
export async function hashPassword(password: string): Promise<string> {
    try {
        if (!password) {
            throw new AppError(400, 'Password is required', errorCodes.INVALID_REQUEST);
        }

        // Enforce password strength
        if (password.length < 8) {
            throw new AppError(400, 'Password must be at least 8 characters long', errorCodes.INVALID_PASSWORD);
        }

        // Generate salt and hash password
        const salt = await bcrypt.genSalt(SALT_ROUNDS);
        const hashedPassword = await bcrypt.hash(password, salt);
        return hashedPassword;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Password hashing failed', errorCodes.PASSWORD_HASH_ERROR);
    }
}

/**
 * Compare a plain text password with a hashed password
 * @param password Plain text password to compare
 * @param hashedPassword Hashed password to compare against
 * @returns Promise resolving to boolean indicating if passwords match
 */
export async function comparePassword(password: string, hashedPassword: string): Promise<boolean> {
    try {
        if (!password || !hashedPassword) {
            throw new AppError(400, 'Password and hashed password are required', errorCodes.INVALID_REQUEST);
        }

        return await bcrypt.compare(password, hashedPassword);
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Password comparison failed', errorCodes.PASSWORD_COMPARE_ERROR);
    }
}

/**
 * Validate password strength
 * @param password Password to validate
 * @returns true if password meets requirements, throws AppError otherwise
 */
export function validatePasswordStrength(password: string): boolean {
    if (!password || typeof password !== 'string') {
        throw new AppError(400, 'Password is required', errorCodes.INVALID_REQUEST);
    }

    // Password requirements
    const minLength = 8;
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

    if (password.length < minLength) {
        throw new AppError(
            400,
            'Password must be at least 8 characters long',
            errorCodes.INVALID_PASSWORD
        );
    }

    if (!hasUpperCase || !hasLowerCase) {
        throw new AppError(
            400,
            'Password must contain both uppercase and lowercase letters',
            errorCodes.INVALID_PASSWORD
        );
    }

    if (!hasNumbers) {
        throw new AppError(
            400,
            'Password must contain at least one number',
            errorCodes.INVALID_PASSWORD
        );
    }

    if (!hasSpecialChar) {
        throw new AppError(
            400,
            'Password must contain at least one special character',
            errorCodes.INVALID_PASSWORD
        );
    }

    return true;
}

/**
 * Generate a secure random password that meets all requirements
 * @param length Length of the password to generate (minimum 8)
 * @returns Generated password
 */
export function generateSecurePassword(length: number = 12): string {
    if (length < 8) {
        throw new AppError(
            400,
            'Password length must be at least 8 characters',
            errorCodes.INVALID_REQUEST
        );
    }

    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#$%^&*(),.?":{}|<>';
    
    let password = '';
    
    // Ensure at least one character from each category
    password += uppercase[Math.floor(Math.random() * uppercase.length)];
    password += lowercase[Math.floor(Math.random() * lowercase.length)];
    password += numbers[Math.floor(Math.random() * numbers.length)];
    password += special[Math.floor(Math.random() * special.length)];
    
    // Fill the rest with random characters
    const allChars = uppercase + lowercase + numbers + special;
    for (let i = password.length; i < length; i++) {
        password += allChars[Math.floor(Math.random() * allChars.length)];
    }
    
    // Shuffle the password
    return password.split('').sort(() => Math.random() - 0.5).join('');
}

/**
 * Generate a JWT token for authentication
 * @param payload User information to encode in the token
 * @returns JWT token string
 */
export function generateToken(payload: TokenPayload): string {
  const secret = process.env.JWT_SECRET || 'fallback_secret_key';
  
  if (!payload.uid) {
    throw new AppError(400, 'User ID is required for token generation', errorCodes.INVALID_REQUEST);
  }

  return jwt.sign(payload, secret, { 
    expiresIn: '24h' 
  });
}

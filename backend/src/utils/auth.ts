import * as bcrypt from 'bcrypt';
import AppError from './AppError'; // Correct import
import { errorCodes } from './errors';

// Number of salt rounds for bcrypt
const SALT_ROUNDS = 12;

/**
 * Hash a password using bcrypt
 * @param password Plain text password to hash
 * @returns Promise resolving to hashed password
 */
export async function hashPassword(password: string): Promise<string> {
    try {
        if (!password) {
            throw new AppError('Password is required', 400, errorCodes.INVALID_INPUT);
        }

        // Enforce password strength
        if (password.length < 8) {
            throw new AppError('Password must be at least 8 characters long', 400, errorCodes.INVALID_PASSWORD);
        }

        // Generate salt and hash password
        const salt = await bcrypt.genSalt(SALT_ROUNDS);
        const hashedPassword = await bcrypt.hash(password, salt);
        return hashedPassword;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError('Password hashing failed', 500, errorCodes.PASSWORD_HASH_ERROR);
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
            throw new AppError('Password and hashed password are required', 400, errorCodes.INVALID_INPUT);
        }

        return await bcrypt.compare(password, hashedPassword);
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError('Password comparison failed', 500, errorCodes.PASSWORD_COMPARE_ERROR);
    }
}

/**
 * Validate password strength
 * @param password Password to validate
 * @returns true if password meets requirements, throws AppError otherwise
 */
export function validatePasswordStrength(password: string): boolean {
    if (!password || typeof password !== 'string') {
        throw new AppError('Password is required', 400, errorCodes.INVALID_INPUT);
    }

    // Password requirements
    const minLength = 8;
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

    if (password.length < minLength) {
        throw new AppError(
            'Password must be at least 8 characters long',
            400,
            errorCodes.INVALID_PASSWORD
        );
    }

    if (!hasUpperCase || !hasLowerCase) {
        throw new AppError(
            'Password must contain both uppercase and lowercase letters',
            400,
            errorCodes.INVALID_PASSWORD
        );
    }

    if (!hasNumbers) {
        throw new AppError(
            'Password must contain at least one number',
            400,
            errorCodes.INVALID_PASSWORD
        );
    }

    if (!hasSpecialChar) {
        throw new AppError(
            'Password must contain at least one special character',
            400,
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
            'Password length must be at least 8 characters',
            400,
            errorCodes.INVALID_INPUT
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

import crypto from 'crypto';

export class CodeGenerator {
    /**
     * Generate a random numeric code of specified length
     * @param length Length of the code to generate
     * @returns Generated numeric code
     */
    static generateNumericCode(length: number = 6): string {
        return Array.from(
            { length },
            () => Math.floor(Math.random() * 10)
        ).join('');
    }

    /**
     * Generate a random alphanumeric code of specified length
     * @param length Length of the code to generate
     * @returns Generated alphanumeric code
     */
    static generateAlphanumericCode(length: number = 8): string {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        return Array.from(
            { length },
            () => chars[Math.floor(Math.random() * chars.length)]
        ).join('');
    }

    /**
     * Generate a secure random token
     * @param length Length of the token in bytes (will be twice this in hex)
     * @returns Generated secure token
     */
    static generateSecureToken(length: number = 32): string {
        return crypto.randomBytes(length).toString('hex');
    }

    /**
     * Generate a referral code
     * @param prefix Optional prefix for the code
     * @returns Generated referral code
     */
    static generateReferralCode(prefix: string = ''): string {
        const code = this.generateAlphanumericCode(6);
        return prefix ? `${prefix}-${code}` : code;
    }

    /**
     * Generate a verification code
     * @returns 6-digit verification code
     */
    static generateVerificationCode(): string {
        return this.generateNumericCode(6);
    }

    /**
     * Generate an affiliate code
     * @param prefix Optional prefix for the code
     * @returns Generated affiliate code
     */
    static generateAffiliateCode(prefix: string = 'AFF'): string {
        const timestamp = Date.now().toString(36).slice(-4);
        const random = this.generateAlphanumericCode(4);
        return `${prefix}${timestamp}${random}`;
    }
}

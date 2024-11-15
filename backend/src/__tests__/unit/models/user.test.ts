import { User, UserRole } from '../../../models/user';
import { describe, expect, it } from '@jest/globals';

describe('User Model', () => {
  const mockUserData: User = {
    uid: '12345',
    email: 'test@example.com',
    displayName: 'John Doe',
    phoneNumber: '+1234567890',
    role: UserRole.CLIENT,
    creationDate: new Date(),
    lastLogin: new Date(),
    address: {
      street: '123 Test St',
      city: 'Test City',
      country: 'Test Country',
      postalCode: '12345'
    }
  };

  it('should validate user data structure', () => {
    const user: User = { ...mockUserData };
    expect(user).toBeDefined();
    expect(user.email).toBe(mockUserData.email);
    expect(user.displayName).toBe(mockUserData.displayName);
    expect(user.role).toBe(UserRole.CLIENT);
  });

  it('should validate email format', () => {
    const invalidUserData: User = {
      ...mockUserData,
      email: 'invalid-email'
    };
    
    expect(invalidUserData.email).not.toMatch(/^[^\s@]+@[^\s@]+\.[^\s@]+$/);
  });
});

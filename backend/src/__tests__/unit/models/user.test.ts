// import { User, UserRole } from '../../../models/user';
// import { Address, AddressType } from '../../../models/address';
// import { describe, expect, it } from '@jest/globals';
// import { Timestamp } from 'firebase-admin/firestore';

// describe('User Model', () => {
//   const mockAddress: Address = {
//     userId: '12345',
//     type: AddressType.HOME,
//     label: 'Home',
//     street: '123 Test St',
//     city: 'Test City',
//     state: 'Test State',
//     country: 'Test Country',
//     postalCode: '12345',
//     coordinates: {
//       latitude: 40.7128,
//       longitude: -74.0060
//     },
//     formattedAddress: '123 Test St, Test City, Test State 12345',
//     contactName: 'John Doe',
//     contactPhone: '+1234567890',
//     isDefault: true,
//     isVerified: false,
//     createdAt: Timestamp.now(),
//     updatedAt: Timestamp.now()
//   };

//   const mockUserData: User = {
//     uid: '12345',
//     email: 'test@example.com',
//     displayName: 'John Doe',
//     phoneNumber: '+1234567890',
//     role: UserRole.CLIENT,
//     creationDate: new Date(),
//     lastLogin: new Date(),
//     address: mockAddress,
//     defaultAddress: mockAddress
//   };

//   it('should validate user data structure', () => {
//     const user: User = { ...mockUserData };
//     expect(user).toBeDefined();
//     expect(user.email).toBe(mockUserData.email);
//     expect(user.displayName).toBe(mockUserData.displayName);
//     expect(user.role).toBe(UserRole.CLIENT);
//     expect(user.defaultAddress?.formattedAddress).toBe(mockAddress.formattedAddress);
//   });

//   it('should validate email format', () => {
//     const invalidUserData: User = {
//       ...mockUserData,
//       email: 'invalid-email'
//     };
    
//     expect(invalidUserData.email).not.toMatch(/^[^\s@]+@[^\s@]+\.[^\s@]+$/);
//   });

//   it('should validate phone number format', () => {
//     const validPhoneNumber = '+1234567890';
//     const invalidPhoneNumber = '123abc';
    
//     expect(mockUserData.phoneNumber).toBe(validPhoneNumber);
//     expect(invalidPhoneNumber).not.toMatch(/^\+[1-9]\d{1,14}$/);
//   });
// });

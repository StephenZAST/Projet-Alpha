import { User } from './types';

export const mockUsers: User[] = [
  {
    id: '1',
    email: 'master@admin.com',
    firstName: 'John',
    lastName: 'Doe',
    adminType: 'MASTER_SUPER_ADMIN',
    permissions: ['all'],
    isActive: true,
    avatar: 'https://ui-avatars.com/api/?name=John+Doe',
    lastLogin: new Date()
  },
  {
    id: '2',
    email: 'super@admin.com',
    firstName: 'Jane',
    lastName: 'Smith',
    adminType: 'SUPER_ADMIN',
    permissions: ['manage_users', 'manage_content', 'view_reports'],
    isActive: true,
    avatar: 'https://ui-avatars.com/api/?name=Jane+Smith',
    lastLogin: new Date()
  }
];

export const findUserByEmail = (email: string): User | undefined => {
  return mockUsers.find(user => user.email === email);
};

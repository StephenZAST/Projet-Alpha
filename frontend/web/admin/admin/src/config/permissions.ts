export type Permission = 'create' | 'read' | 'update' | 'delete';
export type Resource = 'articles' | 'services' | 'categories' | 'users' | 'affiliates';

export const ROLE_PERMISSIONS: Record<string, Record<Resource, Permission[]>> = {
  SUPER_ADMIN: {
    articles: ['create', 'read', 'update', 'delete'],
    services: ['create', 'read', 'update', 'delete'],
    categories: ['create', 'read', 'update', 'delete'],
    users: ['create', 'read', 'update', 'delete'],
    affiliates: ['create', 'read', 'update', 'delete']
  },
  ADMIN: {
    articles: ['create', 'read', 'update'],
    services: ['create', 'read', 'update'],
    categories: ['read'],
    users: ['read'],
    affiliates: ['read', 'update']
  },
  DELIVERY: {
    articles: ['read'],
    services: ['read'],
    categories: ['read'],
    users: ['read'],
    affiliates: ['read']
  }
};

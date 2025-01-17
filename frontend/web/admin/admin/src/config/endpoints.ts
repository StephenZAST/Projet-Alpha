export const ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    ME: '/auth/me'
  },
  ADMIN: {
    STATS: '/admin/stats',
    ORDERS: '/admin/orders',
    SERVICES: '/admin/services',
    ARTICLES: '/admin/articles',
    AFFILIATES: '/admin/affiliates'
  },
  SERVICES: {
    LIST: '/services',
    CREATE: '/services',
    UPDATE: (id: string) => `/services/${id}`,
    DELETE: (id: string) => `/services/${id}`
  },
  ARTICLES: {
    LIST: '/articles',
    CREATE: '/articles',
    UPDATE: (id: string) => `/articles/${id}`,
    DELETE: (id: string) => `/articles/${id}`
  },
  USERS: {
    LIST: '/admin/users',
    DETAILS: (id: string) => `/admin/users/${id}`,
    UPDATE: (id: string) => `/admin/users/${id}`,
    DELETE: (id: string) => `/admin/users/${id}`,
    CREATE: '/admin/users'
  },
  ORDERS: {
    LIST: '/admin/orders',
    DETAILS: (id: string) => `/admin/orders/${id}`,
    UPDATE_STATUS: (id: string) => `/admin/orders/${id}/status`,
    DELETE: (id: string) => `/admin/orders/${id}`,
  },
  AFFILIATES: {
    LIST: '/admin/affiliates',
    DETAILS: (id: string) => `/admin/affiliates/${id}`,
    UPDATE_STATUS: (id: string) => `/admin/affiliates/${id}/status`,
    STATS: (id: string) => `/admin/affiliates/${id}/stats`
  }
};

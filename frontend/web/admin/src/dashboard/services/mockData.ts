// Données mock pour le développement frontend

export const mockTransfers = [
  {
    id: '1',
    from: {
      name: 'Alex Manda',
      avatar: '/avatars/alex.jpg'
    },
    amount: 50,
    date: '2024-01-15',
    time: 'Today, 16:36'
  },
  {
    id: '2',
    to: {
      name: 'Laura Santos',
      avatar: '/avatars/laura.jpg'
    },
    amount: 92,
    date: '2024-01-15',
    time: 'Today, 08:49'
  },
  {
    id: '3',
    from: {
      name: 'Jadon S.',
      avatar: '/avatars/jadon.jpg'
    },
    amount: 157,
    date: '2024-01-14',
    time: 'Yesterday, 14:36'
  }
];

export const mockChartData = [
  { name: 'Jan', value: 400 },
  { name: 'Feb', value: 300 },
  { name: 'Mar', value: 600 },
  { name: 'Apr', value: 400 },
  { name: 'May', value: 500 },
  { name: 'Jun', value: 800 },
  { name: 'Jul', value: 600 },
  { name: 'Aug', value: 700 },
  { name: 'Sep', value: 400 },
  { name: 'Oct', value: 500 },
  { name: 'Nov', value: 300 },
  { name: 'Dec', value: 400 }
];

export const mockStats = [
  {
    title: 'Total Customers',
    value: '5,423',
    icon: '/icons/customers.svg',
    trend: {
      value: '16%',
      direction: 'up' as const,
      text: 'this month'
    }
  },
  {
    title: 'Active Now',
    value: '189',
    icon: '/icons/active.svg'
  },
  {
    title: 'Total Revenue',
    value: '$682.5',
    icon: '/icons/revenue.svg',
    trend: {
      value: '2.45%',
      direction: 'up' as const,
      text: 'vs last month'
    }
  }
];

// Données mock pour MasterSuperAdmin
export const mockMasterAdminData = {
  overview: {
    totalOrders: 15234,
    totalRevenue: 1523400,
    activeUsers: 5423,
    systemHealth: 98.5,
    recentActivities: [
      {
        id: '1',
        user: 'John Admin',
        action: 'Created new admin account',
        timestamp: '2024-01-15T14:30:00'
      },
      // ... plus d'activités
    ]
  },
  adminManagement: {
    totalAdmins: 45,
    activeAdmins: 38,
    recentActions: [
      {
        id: '1',
        admin: 'Sarah Manager',
        action: 'Modified user permissions',
        timestamp: '2024-01-15T15:00:00'
      },
      // ... plus d'actions
    ]
  }
};

// Données mock pour SuperAdmin
export const mockSuperAdminData = {
  overview: {
    dailyOrders: 156,
    monthlyRevenue: 45600,
    activeEmployees: 24,
    customerSatisfaction: 4.8
  },
  staff: {
    totalStaff: 24,
    departments: [
      { name: 'Delivery', count: 12 },
      { name: 'Customer Service', count: 8 },
      { name: 'Management', count: 4 }
    ]
  }
};

// Données mock pour Secretary
export const mockSecretaryData = {
  dailyTasks: [
    {
      id: '1',
      title: 'Process new orders',
      status: 'pending',
      priority: 'high'
    },
    // ... plus de tâches
  ],
  appointments: [
    {
      id: '1',
      title: 'Client Meeting',
      time: '14:00',
      client: 'ABC Corp'
    },
    // ... plus de rendez-vous
  ]
};

// Données mock pour Delivery
export const mockDeliveryData = {
  todayDeliveries: [
    {
      id: '1',
      address: '123 Main St',
      customer: 'John Doe',
      status: 'pending',
      time: '14:00-15:00'
    },
    // ... plus de livraisons
  ],
  route: {
    totalDistance: '45km',
    estimatedTime: '3h 30min',
    stops: [
      { lat: 48.8584, lng: 2.2945 },
      // ... plus de points
    ]
  }
};

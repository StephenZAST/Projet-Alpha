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
    title: 'Total Revenue',
    value: '$54,375',
    icon: 'trending_up',
    trend: {
      value: '12%',
      direction: 'up',
      text: 'vs last month'
    }
  },
  {
    title: 'Active Users',
    value: '2,345',
    icon: 'group',
    trend: {
      value: '8%',
      direction: 'up',
      text: 'vs last month'
    }
  },
  {
    title: 'New Clients',
    value: '321',
    icon: 'person_add',
    trend: {
      value: '5%',
      direction: 'down',
      text: 'vs last month'
    }
  },
  {
    title: 'Satisfaction Rate',
    value: '95%',
    icon: 'sentiment_satisfied',
    trend: {
      value: '3%',
      direction: 'up',
      text: 'vs last month'
    }
  }
];

export const mockMasterAdminData = {
  overview: {
    recentActivities: [
      {
        id: '1',
        user: 'John Doe',
        action: ' added a new admin user',
        timestamp: new Date('2024-01-15T14:30:00').getTime()
      },
      {
        id: '2',
        user: 'Jane Smith',
        action: ' modified system settings',
        timestamp: new Date('2024-01-15T13:45:00').getTime()
      },
      {
        id: '3',
        user: 'Mike Johnson',
        action: ' reviewed security logs',
        timestamp: new Date('2024-01-15T12:15:00').getTime()
      }
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
        timestamp: new Date('2024-01-15T15:00:00').getTime()
      }
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

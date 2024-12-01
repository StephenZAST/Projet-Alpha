export type AdminType = 
  | 'MASTER_SUPER_ADMIN'
  | 'SUPER_ADMIN'
  | 'SUPERVISOR'
  | 'SECRETARY'
  | 'CUSTOMER_SERVICE'
  | 'DELIVERY';

export interface NavItem {
  id: string;
  title: string;
  label: string;
  icon: string;
  path: string;
  children?: NavItem[];
}

export interface AdminNavConfig {
  type: AdminType;
  navItems: NavItem[];
  defaultPath: string;
  defaultView: string;
}

// Configuration des routes pour chaque type d'admin
export const adminNavConfigs: Record<AdminType, AdminNavConfig> = {
  MASTER_SUPER_ADMIN: {
    type: 'MASTER_SUPER_ADMIN',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: [
      {
        id: 'overview',
        title: 'Vue d\'ensemble',
        label: 'Vue d\'ensemble',
        icon: 'dashboard',
        path: 'overview'
      },
      {
        id: 'admin-management',
        title: 'Gestion Admin',
        label: 'Gestion Admin',
        icon: 'admin_panel_settings',
        path: 'admin-management'
      },
      {
        id: 'company',
        title: 'Entreprises',
        label: 'Entreprises',
        icon: 'business',
        path: 'company-management'
      },
      {
        id: 'stats',
        title: 'Statistiques',
        label: 'Statistiques',
        icon: 'analytics',
        path: 'global-stats'
      },
      {
        id: 'settings',
        title: 'Paramètres',
        label: 'Paramètres',
        icon: 'settings',
        path: 'settings'
      }
    ]
  },
  SUPER_ADMIN: {
    type: 'SUPER_ADMIN',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: [
      {
        id: 'overview',
        title: 'Vue d\'ensemble',
        label: 'Vue d\'ensemble',
        icon: 'dashboard',
        path: 'overview'
      },
      {
        id: 'user-management',
        title: 'Gestion Utilisateurs',
        label: 'Gestion Utilisateurs',
        icon: 'group',
        path: 'user-management'
      },
      {
        id: 'content',
        title: 'Contenu',
        label: 'Contenu',
        icon: 'article',
        path: 'content'
      },
      {
        id: 'reports',
        title: 'Rapports',
        label: 'Rapports',
        icon: 'assessment',
        path: 'reports'
      }
    ]
  },
  SUPERVISOR: {
    type: 'SUPERVISOR',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: [
      {
        id: 'overview',
        title: 'Vue d\'ensemble',
        label: 'Vue d\'ensemble',
        icon: 'dashboard',
        path: 'overview'
      },
      {
        id: 'team',
        title: 'Équipe',
        label: 'Équipe',
        icon: 'groups',
        path: 'team'
      },
      {
        id: 'tasks',
        title: 'Tâches',
        label: 'Tâches',
        icon: 'task',
        path: 'tasks'
      }
    ]
  },
  SECRETARY: {
    type: 'SECRETARY',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: [
      {
        id: 'overview',
        title: 'Vue d\'ensemble',
        label: 'Vue d\'ensemble',
        icon: 'dashboard',
        path: 'overview'
      },
      {
        id: 'calendar',
        title: 'Calendrier',
        label: 'Calendrier',
        icon: 'calendar_today',
        path: 'calendar'
      },
      {
        id: 'documents',
        title: 'Documents',
        label: 'Documents',
        icon: 'folder',
        path: 'documents'
      }
    ]
  },
  CUSTOMER_SERVICE: {
    type: 'CUSTOMER_SERVICE',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: [
      {
        id: 'overview',
        title: 'Vue d\'ensemble',
        label: 'Vue d\'ensemble',
        icon: 'dashboard',
        path: 'overview'
      },
      {
        id: 'tickets',
        title: 'Tickets',
        label: 'Tickets',
        icon: 'confirmation_number',
        path: 'tickets'
      },
      {
        id: 'chat',
        title: 'Chat',
        label: 'Chat',
        icon: 'chat',
        path: 'chat'
      }
    ]
  },
  DELIVERY: {
    type: 'DELIVERY',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: [
      {
        id: 'overview',
        title: 'Vue d\'ensemble',
        label: 'Vue d\'ensemble',
        icon: 'dashboard',
        path: 'overview'
      },
      {
        id: 'deliveries',
        title: 'Livraisons',
        label: 'Livraisons',
        icon: 'local_shipping',
        path: 'deliveries'
      },
      {
        id: 'route',
        title: 'Itinéraire',
        label: 'Itinéraire',
        icon: 'map',
        path: 'route'
      }
    ]
  }
};

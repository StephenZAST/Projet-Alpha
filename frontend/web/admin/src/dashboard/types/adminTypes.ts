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
        id: 'company-management',
        title: 'Entreprises',
        label: 'Entreprises',
        icon: 'business',
        path: 'company-management'
      },
      {
        id: 'global-stats',
        title: 'Statistiques Globales',
        label: 'Statistiques Globales',
        icon: 'analytics',
        path: 'global-stats'
      },
      {
        id: 'system-settings',
        title: 'Paramètres Système',
        label: 'Paramètres Système',
        icon: 'settings',
        path: 'system-settings'
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
        id: 'content-management',
        title: 'Gestion Contenu',
        label: 'Gestion Contenu',
        icon: 'article',
        path: 'content-management'
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
    navItems: []
  },
  SECRETARY: {
    type: 'SECRETARY',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: []
  },
  CUSTOMER_SERVICE: {
    type: 'CUSTOMER_SERVICE',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: []
  },
  DELIVERY: {
    type: 'DELIVERY',
    defaultPath: 'overview',
    defaultView: 'Overview',
    navItems: []
  }
};

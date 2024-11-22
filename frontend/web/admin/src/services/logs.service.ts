import api from './api';

export interface SystemLog {
  id: string;
  userId: string;
  action: string;
  resource: string;
  details: string;
  timestamp: string;
  ip: string;
  status: 'success' | 'failure';
}

export interface LogQueryParams {
  startDate?: string;
  endDate?: string;
  userId?: string;
  action?: string;
  status?: 'success' | 'failure';
  page?: number;
  limit?: number;
}

const logsService = {
  // Récupérer tous les logs système
  getAllLogs: (params?: LogQueryParams) => 
    api.get<SystemLog[]>('/admin/logs', { params }),

  // Récupérer les logs récents
  getRecentLogs: () => 
    api.get<SystemLog[]>('/admin/logs/recent'),

  // Récupérer les tentatives de connexion échouées
  getFailedLogins: (adminId: string) => 
    api.get<SystemLog[]>(`/admin/logs/${adminId}/failed-logins`),

  // Récupérer les logs d'un administrateur spécifique
  getAdminLogs: (adminId: string, params?: LogQueryParams) => 
    api.get<SystemLog[]>(`/admin/logs/${adminId}`, { params }),

  // Exporter les logs
  exportLogs: (params?: LogQueryParams) => 
    api.get('/admin/logs/export', { 
      params,
      responseType: 'blob'
    }),
};

export default logsService;

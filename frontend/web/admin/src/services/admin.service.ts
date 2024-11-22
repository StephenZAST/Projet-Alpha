import api from './api';

export interface Admin {
  id: string;
  username: string;
  email: string;
  role: string;
  status: 'active' | 'inactive';
  createdAt: string;
}

export interface AdminCreateInput {
  username: string;
  email: string;
  password: string;
  role: string;
}

export interface AdminUpdateInput {
  username?: string;
  email?: string;
  password?: string;
  role?: string;
  status?: 'active' | 'inactive';
}

const adminService = {
  // Récupérer tous les administrateurs
  getAllAdmins: () => api.get<Admin[]>('/admin'),

  // Récupérer un administrateur par ID
  getAdminById: (id: string) => api.get<Admin>(`/admin/${id}`),

  // Créer un nouvel administrateur
  createAdmin: (data: AdminCreateInput) => api.post<Admin>('/admin', data),

  // Mettre à jour un administrateur
  updateAdmin: (id: string, data: AdminUpdateInput) => 
    api.put<Admin>(`/admin/${id}`, data),

  // Supprimer un administrateur
  deleteAdmin: (id: string) => api.delete(`/admin/${id}`),

  // Changer le statut d'un administrateur
  toggleAdminStatus: (id: string) => 
    api.put<Admin>(`/admin/${id}/status`),

  // Récupérer les logs d'un administrateur
  getAdminLogs: (id: string) => 
    api.get(`/admin/logs/${id}`),

  // Récupérer les statistiques des administrateurs
  getAdminStats: () => 
    api.get('/admin/stats'),
};

export default adminService;

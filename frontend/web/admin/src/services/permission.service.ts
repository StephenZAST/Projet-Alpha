import api from './api';

export interface Permission {
  id: string;
  role: string;
  resource: string;
  actions: string[];
}

export interface PermissionCreateInput {
  role: string;
  resource: string;
  actions: string[];
}

const permissionService = {
  // Récupérer toutes les permissions
  getAllPermissions: () => 
    api.get<Permission[]>('/permissions'),

  // Récupérer les permissions par rôle
  getPermissionsByRole: (role: string) => 
    api.get<Permission[]>(`/permissions/role/${role}`),

  // Créer une nouvelle permission
  createPermission: (data: PermissionCreateInput) => 
    api.post<Permission>('/permissions', data),

  // Mettre à jour une permission
  updatePermission: (id: string, data: Partial<PermissionCreateInput>) => 
    api.put<Permission>(`/permissions/${id}`, data),

  // Supprimer une permission
  deletePermission: (id: string) => 
    api.delete(`/permissions/${id}`),

  // Récupérer la matrice des rôles
  getRoleMatrix: () => 
    api.get('/permissions/matrix'),

  // Initialiser les permissions par défaut
  initializePermissions: () => 
    api.post('/permissions/initialize'),
};

export default permissionService;

export enum AdminAction {
  LOGIN = 'LOGIN',
  LOGOUT = 'LOGOUT',
  CREATE_ADMIN = 'CREATE_ADMIN',
  UPDATE_ADMIN = 'UPDATE_ADMIN',
  DELETE_ADMIN = 'DELETE_ADMIN',
  TOGGLE_STATUS = 'TOGGLE_STATUS',
  FAILED_LOGIN = 'FAILED_LOGIN'
}

export interface IAdminLog {
  id?: string;
  adminId: string;
  action: AdminAction;
  targetAdminId?: string;
  details: string;
  ipAddress: string;
  userAgent: string;
  createdAt: string;
}

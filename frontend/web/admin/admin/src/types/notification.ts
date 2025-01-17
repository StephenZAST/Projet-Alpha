
export interface Notification {
  id: string;
  message: string;
  type: 'info' | 'success' | 'error';
  read: boolean;
  createdAt: string;
}
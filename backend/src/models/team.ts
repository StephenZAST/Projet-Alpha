import { Timestamp } from 'firebase-admin/firestore';

export interface Team {
  id: string;
  name: string;
  description?: string;
  adminIds: string[];
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

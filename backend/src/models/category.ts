export enum CategoryStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  DELETED = 'deleted'
}

export interface Category {
  id?: string;
  name: string;
  description: string;
  status: CategoryStatus;
  createdAt?: string;
  updatedAt?: string;
}

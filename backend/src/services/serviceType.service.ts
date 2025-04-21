import { PrismaClient } from '@prisma/client';
import { ServiceType, NotificationType } from '../models/types';
import { NotificationService } from './notification.service';

const prisma = new PrismaClient();

export class ServiceTypeService {
  static async create(data: Partial<ServiceType>): Promise<ServiceType> {
    try {
      const serviceType = await prisma.service_types.create({
        data: {
          name: data.name!,
          description: data.description || null,
          is_default: data.is_default || false,
          requires_weight: data.requires_weight || false,
          supports_premium: data.supports_premium || false,
          created_at: new Date(),
          updated_at: new Date(),
          is_active: true
        }
      });

      // Notify admins
      await NotificationService.sendNotification(
        'ADMIN',
        NotificationType.SERVICE_TYPE_CREATED,
        {
          serviceTypeId: serviceType.id,
          name: serviceType.name
        }
      );

      return {
        id: serviceType.id,
        name: serviceType.name,
        description: serviceType.description || undefined,
        is_default: serviceType.is_default || false,
        requires_weight: serviceType.requires_weight || false,
        supports_premium: serviceType.supports_premium || false,
        is_active: serviceType.is_active || false,
        created_at: serviceType.created_at || new Date(),
        updated_at: serviceType.updated_at || new Date()
      };
    } catch (error) {
      console.error('Error creating service type:', error);
      throw error;
    }
  }

  static async update(id: string, data: Partial<ServiceType>): Promise<ServiceType> {
    try {
      const serviceType = await prisma.service_types.update({
        where: { id },
        data: {
          ...data,
          updated_at: new Date()
        }
      });

      await NotificationService.sendNotification(
        'ADMIN',
        NotificationType.SERVICE_TYPE_UPDATED,
        {
          serviceTypeId: serviceType.id,
          name: serviceType.name,
          changes: data
        }
      );

      return {
        id: serviceType.id,
        name: serviceType.name,
        description: serviceType.description || undefined,
        is_default: serviceType.is_default || false,
        requires_weight: serviceType.requires_weight || false,
        supports_premium: serviceType.supports_premium || false,
        is_active: serviceType.is_active || false,
        created_at: serviceType.created_at || new Date(),
        updated_at: serviceType.updated_at || new Date()
      };
    } catch (error) {
      console.error('Error updating service type:', error);
      throw error;
    }
  }

  static async updateServiceType(
    id: string,
    data: Partial<{
      name?: string;
      description?: string;
      is_default?: boolean;
      is_active?: boolean;
      requires_weight?: boolean;
      supports_premium?: boolean;
    }>
  ): Promise<ServiceType> {
    try {
      const updatedServiceType = await prisma.service_types.update({
        where: { id },
        data: {
          ...data,
          updated_at: new Date()
        }
      });

      return {
        id: updatedServiceType.id,
        name: updatedServiceType.name,
        description: updatedServiceType.description || undefined,
        is_default: updatedServiceType.is_default || false,
        requires_weight: updatedServiceType.requires_weight || false,
        supports_premium: updatedServiceType.supports_premium || false,
        is_active: updatedServiceType.is_active || false,
        created_at: updatedServiceType.created_at || new Date(),
        updated_at: updatedServiceType.updated_at || new Date()
      };
    } catch (error) {
      console.error('Error updating service type:', error);
      throw error;
    }
  }

  static async delete(id: string): Promise<void> {
    try {
      await prisma.service_types.delete({
        where: { id }
      });
    } catch (error) {
      console.error('Error deleting service type:', error);
      throw error;
    }
  }

  static async getById(id: string): Promise<ServiceType | null> {
    try {
      const serviceType = await prisma.service_types.findUnique({
        where: { id }
      });

      if (!serviceType) return null;

      return {
        id: serviceType.id,
        name: serviceType.name,
        description: serviceType.description || undefined,
        is_default: serviceType.is_default || false,
        requires_weight: serviceType.requires_weight || false,
        supports_premium: serviceType.supports_premium || false,
        is_active: serviceType.is_active || false,
        created_at: serviceType.created_at || new Date(),
        updated_at: serviceType.updated_at || new Date()
      };
    } catch (error) {
      console.error('Error getting service type:', error);
      throw error;
    }
  }

  static async getAll(includeInactive = false): Promise<ServiceType[]> {
    try {
      const serviceTypes = await prisma.service_types.findMany({
        where: includeInactive ? undefined : {
          is_active: true
        },
        orderBy: {
          name: 'asc'
        }
      });

      return serviceTypes.map(st => ({
        id: st.id,
        name: st.name,
        description: st.description || undefined,
        is_default: st.is_default || false,
        requires_weight: st.requires_weight || false,
        supports_premium: st.supports_premium || false,
        is_active: st.is_active || false,
        created_at: st.created_at || new Date(),
        updated_at: st.updated_at || new Date()
      }));
    } catch (error) {
      console.error('Error getting service types:', error);
      throw error;
    }
  }

  static async getDefaultServiceType(): Promise<ServiceType | null> {
    try {
      const serviceType = await prisma.service_types.findFirst({
        where: {
          is_default: true,
          is_active: true
        }
      });

      if (!serviceType) return null;

      return {
        id: serviceType.id,
        name: serviceType.name,
        description: serviceType.description || undefined,
        is_default: serviceType.is_default || false,
        requires_weight: serviceType.requires_weight || false,
        supports_premium: serviceType.supports_premium || false,
        is_active: serviceType.is_active || false,
        created_at: serviceType.created_at || new Date(),
        updated_at: serviceType.updated_at || new Date()
      };
    } catch (error) {
      console.error('Error getting default service type:', error);
      throw error;
    }
  }
}

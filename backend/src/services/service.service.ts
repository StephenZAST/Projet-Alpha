import { PrismaClient } from '@prisma/client';
import { Service } from '../models/types';

const prisma = new PrismaClient();

export class ServiceService {
  static async createService(name: string, price: number, description?: string): Promise<Service> {
    try {
      const service = await prisma.services.create({
        data: {
          name,
          price,
          description: description || null,
          created_at: new Date(),
          updated_at: new Date()
        }
      });

      return {
        id: service.id,
        name: service.name,
        price: service.price || 0,
        description: service.description || undefined,
        createdAt: service.created_at || new Date(),
        updatedAt: service.updated_at || new Date()
      };
    } catch (error) {
      console.error('Create service error:', error);
      throw error;
    }
  }

  static async getAllServices(): Promise<Service[]> {
    try {
      const services = await prisma.services.findMany({
        orderBy: {
          created_at: 'desc'
        }
      });

      return services.map(service => ({
        id: service.id,
        name: service.name,
        price: service.price || 0,
        description: service.description || undefined,
        createdAt: service.created_at || new Date(),
        updatedAt: service.updated_at || new Date(),
        service_type_id: service.service_type_id ?? undefined // Corrige le type pour éviter null
      }));
    } catch (error) {
      console.error('Get all services error:', error);
      throw error;
    }
  }

  static async updateService(serviceId: string, name: string, price: number, description?: string, service_type_id?: string): Promise<Service> {
    try {
      const updateData: any = {
        name,
        price,
        description: description || null,
        updated_at: new Date()
      };
      if (service_type_id) {
        updateData.service_type_id = service_type_id;
      }
      const service = await prisma.services.update({
        where: { id: serviceId },
        data: updateData
      });

      return {
        id: service.id,
        name: service.name,
        price: service.price || 0,
        description: service.description || undefined,
        createdAt: service.created_at || new Date(),
        updatedAt: service.updated_at || new Date(),
        service_type_id: service.service_type_id ?? undefined
      };
    } catch (error) {
      console.error('Update service error:', error);
      throw error;
    }
  }

  static async deleteService(serviceId: string): Promise<void> {
    try {
      await prisma.services.delete({
        where: { id: serviceId }
      });
    } catch (error) {
      console.error('Delete service error:', error);
      throw error;
    }
  }
}

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class DefaultServiceService {
  static async setDefaultService(
    categoryId: string,
    serviceId: string,
    restrictions: string[] = []
  ) {
    try {
      // Mettre à jour ou créer le service par défaut
      const data = await prisma.service_types.upsert({
        where: {
          id: serviceId
        },
        update: {
          is_default: true,
          updated_at: new Date()
        },
        create: {
          id: serviceId,
          name: '',  // Requis par le schéma
          is_default: true,
          created_at: new Date(),
          updated_at: new Date()
        },
        include: {
          services: true
        }
      });

      // Désactiver les autres services par défaut de la catégorie
      await prisma.service_types.updateMany({
        where: {
          id: {
            not: serviceId
          }
        },
        data: {
          is_default: false,
          updated_at: new Date()
        }
      });

      return {
        id: data.id,
        serviceId: data.id,
        categoryId,
        restrictions,
        service: data.services?.[0],
        updatedAt: data.updated_at
      };
    } catch (error) {
      console.error('[DefaultServiceService] Set default service error:', error);
      throw error;
    }
  }

  static async getDefaultServices(categoryId: string) {
    try {
      const services = await prisma.service_types.findMany({
        where: {
          is_default: true
        },
        include: {
          services: true
        }
      });

      return services.map(service => ({
        id: service.id,
        serviceId: service.id,
        categoryId,
        service: service.services?.[0],
        restrictions: [],
        updatedAt: service.updated_at
      }));
    } catch (error) {
      console.error('[DefaultServiceService] Get default services error:', error);
      throw error;
    }
  }

  static async removeDefaultService(categoryId: string, serviceId: string) {
    try {
      await prisma.service_types.update({
        where: {
          id: serviceId
        },
        data: {
          is_default: false,
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[DefaultServiceService] Remove default service error:', error);
      throw error;
    }
  }
}

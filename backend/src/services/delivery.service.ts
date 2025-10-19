import { PrismaClient } from '@prisma/client';
import { Order, OrderStatus } from '../models/types';

const prisma = new PrismaClient();

export class DeliveryService {
  static async getPendingOrders(userId: string): Promise<Order[]> {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          userId,
          status: 'PENDING'
        },
        include: {
          service_types: true,
          order_metadata: true,
          user: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          address: {
            select: {
              id: true,
              street: true,
              city: true,
              postal_code: true,
              gps_latitude: true,
              gps_longitude: true,
              name: true
            }
          },
          order_items: {
            include: {
              article: {
                select: {
                  id: true,
                  name: true,
                  article_categories: {
                    select: {
                      name: true
                    }
                  }
                }
              }
            }
          }
        }
      });
      return orders as unknown as Order[];
    } catch (error) {
      console.error('Get pending orders error:', error);
      throw error;
    }
  }

  static async getAssignedOrders(userId: string): Promise<Order[]> {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          userId,
          status: 'COLLECTING'
        },
        include: {
          service_types: true,
          order_metadata: true,
          user: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          address: {
            select: {
              id: true,
              street: true,
              city: true,
              postal_code: true,
              gps_latitude: true,
              gps_longitude: true,
              name: true
            }
          },
          order_items: {
            include: {
              article: {
                select: {
                  id: true,
                  name: true,
                  article_categories: {
                    select: {
                      name: true
                    }
                  }
                }
              }
            }
          }
        }
      });
      return orders as unknown as Order[];
    } catch (error) {
      console.error('Get assigned orders error:', error);
      throw error;
    }
  }

  static async getDraftOrders(userId: string): Promise<Order[]> {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          userId,
          status: 'DRAFT'
        },
        include: {
          service_types: true,
          order_metadata: true,
          user: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          address: {
            select: {
              id: true,
              street: true,
              city: true,
              postal_code: true,
              gps_latitude: true,
              gps_longitude: true,
              name: true
            }
          },
          order_items: {
            include: {
              article: {
                select: {
                  id: true,
                  name: true,
                  article_categories: {
                    select: {
                      name: true
                    }
                  }
                }
              }
            }
          }
        }
      });
      return orders as unknown as Order[];
    } catch (error) {
      console.error('Get draft orders error:', error);
      throw error;
    }
  }

  static async getOrdersByStatus(userId: string, status: OrderStatus): Promise<Order[]> {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          userId,
          status
        },
        include: {
          service_types: true,
          order_metadata: true,
          user: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          address: {
            select: {
              id: true,
              street: true,
              city: true,
              postal_code: true,
              gps_latitude: true,
              gps_longitude: true,
              name: true
            }
          },
          order_items: {
            include: {
              article: {
                select: {
                  id: true,
                  name: true,
                  article_categories: {
                    select: {
                      name: true
                    }
                  }
                }
              }
            }
          }
        }
      });
      return orders as unknown as Order[];
    } catch (error) {
      console.error(`Get ${status} orders error:`, error);
      throw error;
    }
  }

  static async updateOrderStatus(orderId: string, status: OrderStatus, userId: string): Promise<Order> {
    try {
      // First check if order exists and user has access
      const existingOrder = await prisma.orders.findFirst({
        where: {
          id: orderId,
          userId
        },
        include: {
          service_types: true,
          order_metadata: true
        }
      });

      if (!existingOrder) {
        throw new Error('Order not found or unauthorized');
      }

      // Update the order status
      const updatedOrder = await prisma.orders.update({
        where: {
          id: orderId
        },
        data: {
          status,
          updatedAt: new Date()
        },
        include: {
          service_types: true,
          order_metadata: true,
          user: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          address: {
            select: {
              id: true,
              street: true,
              city: true,
              postal_code: true,
              gps_latitude: true,
              gps_longitude: true,
              name: true
            }
          },
          order_items: {
            include: {
              article: {
                select: {
                  id: true,
                  name: true,
                  article_categories: {
                    select: {
                      name: true
                    }
                  }
                }
              }
            }
          }
        }
      });

      return updatedOrder as unknown as Order;
    } catch (error) {
      console.error('Update order status error:', error);
      throw error;
    }
  }

  // Helper method for getting orders by any status
  static getCOLLECTEDOrders = (userId: string) => this.getOrdersByStatus(userId, 'COLLECTED');
  static getPROCESSINGOrders = (userId: string) => this.getOrdersByStatus(userId, 'PROCESSING');
  static getREADYOrders = (userId: string) => this.getOrdersByStatus(userId, 'READY');
  static getDELIVERINGOrders = (userId: string) => this.getOrdersByStatus(userId, 'DELIVERING');
  static getDELIVEREDOrders = (userId: string) => this.getOrdersByStatus(userId, 'DELIVERED');
  static getCANCELLEDOrders = (userId: string) => this.getOrdersByStatus(userId, 'CANCELLED');
}

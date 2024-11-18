import swaggerJsdoc from 'swagger-jsdoc';
import { version } from '../../package.json';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Alpha Laundry Service API',
      version,
      description: 'Comprehensive REST API for Alpha laundry service management system, featuring order processing, delivery optimization, real-time tracking, and more.',
      license: {
        name: 'Proprietary',
        url: 'https://alpha-laundry.com/terms',
      },
      contact: {
        name: 'Alpha Laundry Support',
        email: 'support@alpha-laundry.com',
      },
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Development Server',
      },
      {
        url: 'https://api.alpha-laundry.com',
        description: 'Production Server',
      },
    ],
    tags: [
      { name: 'Authentication', description: 'User authentication and authorization endpoints' },
      { name: 'Users', description: 'User management operations' },
      { name: 'Orders', description: 'Order processing and management' },
      { name: 'Delivery', description: 'Delivery tasks and route optimization' },
      { name: 'Affiliate', description: 'Affiliate program management' },
      { name: 'Loyalty', description: 'Customer loyalty program' },
      { name: 'Billing', description: 'Billing and payment operations' },
      { name: 'Analytics', description: 'Business analytics and reporting' },
      { name: 'WebSocket', description: 'Real-time communication endpoints' }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            error: {
              type: 'object',
              properties: {
                code: {
                  type: 'string',
                  example: 'INVALID_INPUT',
                },
                message: {
                  type: 'string',
                  example: 'Invalid input parameters',
                },
                details: {
                  type: 'object',
                  example: {},
                },
              },
            },
          },
        },
        GeoLocation: {
          type: 'object',
          properties: {
            latitude: {
              type: 'number',
              format: 'float',
              example: 6.1377,
            },
            longitude: {
              type: 'number',
              format: 'float',
              example: -10.7969,
            },
            geohash: {
              type: 'string',
              example: 'ebz2s5p',
            },
          },
          required: ['latitude', 'longitude'],
        },
        DeliveryTask: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              example: 'task123',
            },
            orderId: {
              type: 'string',
              example: 'order456',
            },
            status: {
              type: 'string',
              enum: ['PENDING', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'],
            },
            assignedDriver: {
              type: 'string',
              example: 'driver789',
            },
            pickupLocation: {
              $ref: '#/components/schemas/GeoLocation',
            },
            deliveryLocation: {
              $ref: '#/components/schemas/GeoLocation',
            },
            scheduledTime: {
              type: 'object',
              properties: {
                date: {
                  type: 'string',
                  format: 'date-time',
                },
                duration: {
                  type: 'number',
                  description: 'Duration in minutes',
                },
              },
            },
            priority: {
              type: 'string',
              enum: ['low', 'medium', 'high', 'urgent'],
            },
          },
        },
        Order: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              example: 'order123',
            },
            userId: {
              type: 'string',
              example: 'user456',
            },
            type: {
              type: 'string',
              enum: ['STANDARD', 'ONE_CLICK', 'SUBSCRIPTION'],
            },
            serviceType: {
              type: 'string',
              enum: ['PRESSING', 'REPASSAGE', 'NETTOYAGE'],
            },
            items: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  itemType: {
                    type: 'string',
                    example: 'shirt',
                  },
                  quantity: {
                    type: 'number',
                    example: 2,
                  },
                  notes: {
                    type: 'string',
                    example: 'Light starch',
                  },
                },
              },
            },
            status: {
              type: 'string',
              enum: ['PENDING', 'ACCEPTED', 'PICKED_UP', 'IN_PROGRESS', 'READY', 'DELIVERING', 'DELIVERED'],
            },
            pickupAddress: {
              type: 'string',
              example: '123 Main St',
            },
            deliveryAddress: {
              type: 'string',
              example: '456 Oak Ave',
            },
            scheduledPickupTime: {
              type: 'string',
              format: 'date-time',
            },
            scheduledDeliveryTime: {
              type: 'string',
              format: 'date-time',
            },
            totalAmount: {
              type: 'number',
              example: 25000,
            },
            loyaltyPoints: {
              type: 'number',
              example: 250,
            },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              example: 'user123',
            },
            email: {
              type: 'string',
              format: 'email',
            },
            role: {
              type: 'string',
              enum: ['SUPER_ADMIN', 'ADMIN', 'SECRETAIRE', 'LIVREUR', 'SUPERVISEUR', 'AFFILIATE', 'CLIENT'],
            },
            status: {
              type: 'string',
              enum: ['ACTIVE', 'INACTIVE', 'SUSPENDED'],
            },
            profile: {
              type: 'object',
              properties: {
                firstName: {
                  type: 'string',
                },
                lastName: {
                  type: 'string',
                },
                phone: {
                  type: 'string',
                },
                address: {
                  type: 'string',
                },
              },
            },
          },
        },
        WebSocketMessage: {
          type: 'object',
          properties: {
            type: {
              type: 'string',
              enum: ['location', 'geofence', 'task', 'error'],
            },
            payload: {
              type: 'object',
            },
          },
        },
      },
    },
  },
  apis: ['./src/routes/*.ts'], // Chemins des fichiers contenant la documentation
};

export default swaggerJsdoc(options);

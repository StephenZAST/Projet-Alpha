import { Express, Request, Response } from 'express';
import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';

const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'Alpha Laundry API Documentation',
    version: '1.0.0',
    description: 'API documentation for Alpha Laundry Service',
    contact: {
      name: 'Alpha Laundry Support',
      email: 'support@alphalaundry.com'
    }
  },
  servers: [
    {
      url: 'http://localhost:3000',
      description: 'Development server'
    }
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT'
      }
    },
    schemas: {
      Affiliate: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          fullName: { type: 'string' },
          email: { type: 'string', format: 'email' },
          phone: { type: 'string' },
          status: { type: 'string', enum: ['PENDING', 'ACTIVE', 'SUSPENDED'] },
          paymentInfo: {
            type: 'object',
            properties: {
              preferredMethod: { type: 'string', enum: ['MOBILE_MONEY', 'BANK_TRANSFER'] },
              mobileMoneyNumber: { type: 'string' }
            }
          },
          totalEarnings: { type: 'number' },
          availableBalance: { type: 'number' },
          referralCode: { type: 'string' }
        }
      },
      Commission: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          affiliateId: { type: 'string' },
          orderId: { type: 'string' },
          orderAmount: { type: 'number' },
          commissionAmount: { type: 'number' },
          status: { type: 'string', enum: ['PENDING', 'APPROVED', 'PAID'] }
        }
      },
      Delivery: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          orderId: { type: 'string' },
          status: { type: 'string', enum: ['PENDING', 'PICKUP_SCHEDULED', 'IN_TRANSIT', 'DELIVERED'] },
          timeSlot: {
            type: 'object',
            properties: {
              start: { type: 'string', format: 'date-time' },
              end: { type: 'string', format: 'date-time' }
            }
          },
          location: {
            type: 'object',
            properties: {
              latitude: { type: 'number' },
              longitude: { type: 'number' }
            }
          }
        }
      },
      Error: {
        type: 'object',
        properties: {
          code: { type: 'string' },
          message: { type: 'string' }
        }
      },
      WebSocketEvent: {
        type: 'object',
        properties: {
          event: {
            type: 'string',
            description: 'WebSocket event name',
            enum: [
              'delivery:track', 
              'delivery:status', 
              'order:status', 
              'order:update'
            ]
          },
          data: {
            type: 'object',
            description: 'Event payload data'
          }
        }
      }
    }
  },
  paths: {
    '/socket.io': {
      get: {
        summary: 'WebSocket Connection',
        description: 'Establish a real-time WebSocket connection',
        tags: ['WebSocket'],
        responses: {
          '101': {
            description: 'WebSocket connection established',
            content: {
              'application/json': {
                schema: {
                  $ref: '#/components/schemas/WebSocketEvent'
                }
              }
            }
          }
        }
      }
    }
  },
  security: [
    {
      bearerAuth: []
    }
  ]
};

const options = {
  swaggerDefinition,
  apis: ['./src/routes/*.ts']
};

const swaggerSpec = swaggerJsdoc(options);

export const setupSwagger = (app: Express) => {
  // Swagger page
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  // Docs in JSON format
  app.get('/docs.json', (req: Request, res: Response) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpec);
  });
};

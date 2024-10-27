import request from 'supertest';
import app from '../../app';
import { createTestToken } from '../utils/auth';

describe('Article Routes', () => {
  const adminToken = createTestToken({ role: 'admin' });
  
  describe('GET /api/articles', () => {
    test('returns list of articles', async () => {
      const response = await request(app)
        .get('/api/articles')
        .expect(200);
      
      expect(Array.isArray(response.body)).toBe(true);
    });
  });

  describe('POST /api/articles', () => {
    test('creates new article with valid admin token', async () => {
      const response = await request(app)
        .post('/api/articles')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          articleName: 'New Article',
          articleCategory: 'Chemisier',
          prices: {
            [MainService.WASH_AND_IRON]: {
              [PriceType.STANDARD]: 500
            }
          },
          availableServices: [MainService.WASH_AND_IRON]
        })
        .expect(201);

      expect(response.body.articleName).toBe('New Article');
    });
  });
});

import { expect } from 'chai';
import supertest from 'supertest';

const API_URL = 'http://localhost:3001';
const request = supertest(API_URL);

// Token que vous avez déjà obtenu du serveur en cours d'exécution
const ADMIN_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjBjNTMyMzQ4LTFhYWQtNDNlNy05NDgzLTMxNDRjNDI5N2M0NiIsInJvbGUiOiJTVVBFUl9BRE1JTiIsImlhdCI6MTczODc2NDcwNSwiZXhwIjoxNzM5MzY5NTA1fQ.YYbCsSWNP8o7qvhuW1ueYceYnH1tvq1uxtVd872Ufzk'; // À remplacer par votre token 

describe('Flash Orders Draft Endpoint Tests', () => {
  describe('GET /api/orders/flash/draft', () => {
    it('should return flash orders in DRAFT status', async () => {
      const response = await request
        .get('/api/orders/flash/draft')
        .set('Authorization', `Bearer ${ADMIN_TOKEN}`);

      console.log('Response:', {
        status: response.status,
        body: response.body
      });

      expect(response.status).to.equal(200);
      expect(response.body).to.have.property('data');
      expect(Array.isArray(response.body.data)).to.be.true;

      // Vérification des champs de chaque commande
      if (response.body.data.length > 0) {
        const order = response.body.data[0];
        expect(order).to.have.property('id');
        expect(order).to.have.property('status', 'DRAFT');
        expect(order).to.have.property('userId');
        expect(order).to.have.property('addressId');
      }
    });

    it('should create and retrieve a flash order', async () => {
      // 1. Créer une commande flash
      const createResponse = await request
        .post('/api/orders/flash')
        .set('Authorization', `Bearer ${ADMIN_TOKEN}`)
        .send({
          addressId: '03802428-7c13-4e06-b153-bb5a9dde176a', // Utiliser un ID existant
          notes: 'Test flash order'
        });

      expect(createResponse.status).to.equal(200);
      expect(createResponse.body.data).to.have.property('id');

      const orderId = createResponse.body.data.id;

      // 2. Vérifier que la commande est bien dans les drafts
      const getResponse = await request
        .get('/api/orders/flash/draft')
        .set('Authorization', `Bearer ${ADMIN_TOKEN}`);

      const foundOrder = getResponse.body.data.find((o: any) => o.id === orderId);
      expect(foundOrder).to.not.be.undefined;
      expect(foundOrder.status).to.equal('DRAFT');
    });
  });
});

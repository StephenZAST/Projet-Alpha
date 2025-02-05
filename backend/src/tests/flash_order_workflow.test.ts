import axios from 'axios';
import { v4 as uuidv4 } from 'uuid';

const API_URL = 'http://localhost:3001/api';

describe('Workflow Commande Flash', () => {
  // Configuration du test
  const TEST_DATA = {
    addressId: uuidv4(),
    serviceId: uuidv4(),
    affiliateCode: null as string | null,
    items: [
      {
        articleId: uuidv4(),
        quantity: 2,
        unitPrice: 10.99
      }
    ]
  };

  // 1. Test de création commande flash
  async function testCreateFlashOrder() {
    const createResponse = await axios.post(`${API_URL}/orders/flash`, {
      addressId: TEST_DATA.addressId,
      notes: "Test workflow commande flash"
    });

    expect(createResponse.data.data.order).toHaveProperty('id');
    expect(createResponse.data.data.order.status).toBe('DRAFT');
    
    return createResponse.data.data.order;
  }

  // 2. Test de complétion de commande flash
  async function testCompleteFlashOrder(orderId: string) {
    const completeResponse = await axios.patch(
      `${API_URL}/orders/flash/${orderId}/complete`,
      {
        serviceId: TEST_DATA.serviceId,
        items: TEST_DATA.items.map(item => ({
          articleId: item.articleId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          isPremium: false
        }))
      }
    );

    const completedOrder = completeResponse.data.data.order;
    
    // Vérifications clés basées sur les fonctions stockées
    expect(completedOrder.status).toBe('PENDING');  // Vérifie la transition DRAFT -> PENDING
    expect(completedOrder.serviceId).toBe(TEST_DATA.serviceId);
    expect(completedOrder.items).toHaveLength(TEST_DATA.items.length);
    
    // Vérifier le calcul du total (logique de create_order_with_items)
    const expectedTotal = TEST_DATA.items.reduce(
      (sum, item) => sum + (item.quantity * item.unitPrice), 
      0
    );
    expect(completedOrder.totalAmount).toBe(expectedTotal);

    return completedOrder;
  }

  // 3. Test de vérification des données liées
  async function testRelatedData(orderId: string) {
    // Vérifier les order_items
    const orderItemsResponse = await axios.get(`${API_URL}/orders/${orderId}/items`);
    expect(orderItemsResponse.data).toHaveProperty('length');
    
    // Vérifier les points de fidélité (si applicable)
    const loyaltyResponse = await axios.get(`${API_URL}/loyalty/points`);
    expect(loyaltyResponse.data).toHaveProperty('pointsBalance');
    
    // Vérifier la commission d'affiliation (si applicable)
    if (TEST_DATA.affiliateCode) {
      const affiliateResponse = await axios.get(`${API_URL}/affiliate/commission`);
      expect(affiliateResponse.data).toHaveProperty('commissionBalance');
    }
  }

  // Test principal qui exécute le workflow complet
  it('should complete full flash order workflow', async () => {
    try {
      // 1. Créer la commande flash
      const flashOrder = await testCreateFlashOrder();
      console.log('Commande flash créée:', flashOrder.id);

      // 2. Compléter la commande
      const completedOrder = await testCompleteFlashOrder(flashOrder.id);
      console.log('Commande complétée:', completedOrder.id);

      // 3. Vérifier les données associées
      await testRelatedData(completedOrder.id);
      console.log('Vérifications complémentaires OK');
      
    } catch (error) {
      console.error('Erreur dans le workflow:', error);
      throw error;
    }
  });
});

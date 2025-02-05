import axios from 'axios';
import { config } from 'dotenv';
import chalk from 'chalk';

// Charger les variables d'environnement
config();

const API_URL = process.env.API_URL || 'http://localhost:3001/api';

interface TestData {
  token: string;
  serviceId: string;
  items: Array<{
    articleId: string;
    quantity: number;
    unitPrice: number;
  }>;
  addressId: string;
}

const TEST_DATA: TestData = {
  token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA2NjU3ZWYxLTJjOGUtNDAzMy1hZWIzLThhY2I5OGZlMWQxYyIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTczODcyNTg5NSwiZXhwIjoxNzM5MzMwNjk1fQ.vgQkXEXuCdVSXBScsx8hzm3PXdtqcd3Pp-_LUfxUXWc", // Votre token
  serviceId: "235d24ef-836d-4e87-aef1-bf028d5d8e3d",
  addressId: "03802428-7c13-4e06-b153-bb5a9dde176a",
  items: [
    {
      articleId: "b75ab8ac-58ef-4cdb-b57e-6c8722449cce",
      quantity: 4,
      unitPrice: 15
    }
  ]
};

const log = {
  info: (msg: string) => console.log(chalk.blue('ℹ'), msg),
  success: (msg: string) => console.log(chalk.green('✓'), msg),
  error: (msg: string) => console.log(chalk.red('✗'), msg),
  warning: (msg: string) => console.log(chalk.yellow('⚠'), msg),
  section: (msg: string) => console.log('\n' + chalk.cyan('▶'), chalk.bold(msg))
};

async function testCompleteFlashOrder() {
  try {
    log.section('Test de conversion d\'une commande flash');
    
    // 1. Créer une commande flash
    log.info('Création d\'une commande flash de test...');
    const flashOrder = await createFlashOrder();
    log.success(`Commande flash créée avec ID: ${flashOrder.id}`);

    // 2. Vérifier l'état initial
    log.info('Vérification de l\'état initial...');
    await verifyInitialState(flashOrder.id);
    
    // 3. Compléter la commande flash
    log.info('Mise à jour de la commande flash...');
    const completedOrder = await completeFlashOrder(flashOrder.id);
    log.success('Commande mise à jour avec succès');

    // 4. Vérifications détaillées
    log.section('Vérifications');
    await runValidations(completedOrder);

  } catch (error: any) {
    log.error('Erreur pendant les tests:');
    console.error(error.response?.data || error.message);
    process.exit(1);
  }
}

async function createFlashOrder() {
  const { data } = await axios.post(
    `${API_URL}/orders/flash`,
    {
      addressId: TEST_DATA.addressId,
      notes: "Test de conversion commande flash"
    },
    {
      headers: { 'Authorization': `Bearer ${TEST_DATA.token}` }
    }
  );
  return data.data;
}

async function verifyInitialState(orderId: string) {
  const { data } = await axios.get(
    `${API_URL}/orders/${orderId}`,
    {
      headers: { 'Authorization': `Bearer ${TEST_DATA.token}` }
    }
  );
  
  const order = data.data;
  if (order.status !== 'DRAFT') {
    throw new Error(`État initial incorrect. Attendu: DRAFT, Reçu: ${order.status}`);
  }
  log.success('État initial vérifié: DRAFT');
}

async function completeFlashOrder(orderId: string) {
  const { data } = await axios.patch(
    `${API_URL}/orders/flash/${orderId}/complete`,
    {
      serviceId: TEST_DATA.serviceId,
      items: TEST_DATA.items,
      collectionDate: new Date(Date.now() + 86400000).toISOString(), // +24h
      deliveryDate: new Date(Date.now() + 172800000).toISOString(), // +48h
    },
    {
      headers: { 'Authorization': `Bearer ${TEST_DATA.token}` }
    }
  );
  return data.data;
}

async function runValidations(completedOrder: any) {
  const validations = [
    {
      name: 'Status',
      test: () => completedOrder.status === 'PENDING',
      expected: 'PENDING',
      received: completedOrder.status
    },
    {
      name: 'Service',
      test: () => completedOrder.serviceId === TEST_DATA.serviceId,
      expected: TEST_DATA.serviceId,
      received: completedOrder.serviceId
    },
    {
      name: 'Articles',
      test: () => completedOrder.items?.length === TEST_DATA.items.length,
      expected: TEST_DATA.items.length,
      received: completedOrder.items?.length
    },
    {
      name: 'Total',
      test: () => {
        const expectedTotal = TEST_DATA.items.reduce(
          (sum, item) => sum + (item.quantity * item.unitPrice), 
          0
        );
        return completedOrder.totalAmount === expectedTotal;
      },
      expected: TEST_DATA.items[0].quantity * TEST_DATA.items[0].unitPrice,
      received: completedOrder.totalAmount
    }
  ];

  for (const validation of validations) {
    if (validation.test()) {
      log.success(`${validation.name}: OK`);
    } else {
      log.error(`${validation.name}: NOK`);
      log.warning(`Attendu: ${validation.expected}`);
      log.warning(`Reçu: ${validation.received}`);
    }
  }
}

// Exécuter les tests
testCompleteFlashOrder().catch(console.error);

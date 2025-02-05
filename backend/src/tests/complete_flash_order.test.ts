import axios, { AxiosError } from 'axios';

// Configuration
const API_URL = 'http://localhost:3001/api';
const MAX_RETRIES = 3;
const RETRY_DELAY = 1000; // 1 seconde

// Mise à jour de l'interface pour correspondre à la structure exacte de la BD
interface OrderResponse {
  id: string;
  userId: string;
  addressId: string;
  status: string;
  totalAmount: number;
  serviceId: string | null;
  items: Array<{
    id: string;
    orderId: string;
    articleId: string;
    quantity: number;
    unitPrice: number;
  }>;
}

interface FlashOrderCompletion {
  // Champs requis
  serviceId: string;
  items: Array<{
    articleId: string;
    quantity: number;
    unitPrice: number;
    isPremium: boolean;
  }>;
  // Champs optionnels
  collectionDate?: string;  // ISO string
  deliveryDate?: string;    // ISO string
}

interface CreateFlashOrderResponse {
  success: boolean;
  data: {
    id: string;
    addressId: string;
    userId: string;
    status: string;
    notes?: string;
    createdAt: string;
    updatedAt: string;
  };
}

const TEST_DATA = {
  token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA2NjU3ZWYxLTJjOGUtNDAzMy1hZWIzLThhY2I5OGZlMWQxYyIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTczODcyNTg5NSwiZXhwIjoxNzM5MzMwNjk1fQ.vgQkXEXuCdVSXBScsx8hzm3PXdtqcd3Pp-_LUfxUXWc",
  serviceId: "235d24ef-836d-4e87-aef1-bf028d5d8e3d",
  addressId: "03802428-7c13-4e06-b153-bb5a9dde176a",
  items: [{
    articleId: "b75ab8ac-58ef-4cdb-b57e-6c8722449cce",
    quantity: 4,
    unitPrice: 15
  }]
};

const log = {
  info: (msg: string) => console.log('\n📝', msg),
  success: (msg: string) => console.log('\n✅', msg),
  error: (msg: string, error?: any) => {
    console.log('\n❌', msg);
    if (error instanceof AxiosError) {
      if (error.code === 'ECONNREFUSED') {
        console.log('\n⚠️ Le serveur n\'est pas accessible. Vérifiez que:');
        console.log('1. Le serveur backend est démarré (npm run dev)');
        console.log('2. Le port 3001 est correct');
        console.log('3. L\'URL est correcte:', API_URL);
      } else if (error.response) {
        console.log('Status:', error.response.status);
        console.log('Message:', error.response.data);
      }
    } else {
      console.log('Erreur:', error?.message || error);
    }
  }
};

// Fonction améliorée pour vérifier si le serveur est accessible
async function checkServer(): Promise<boolean> {
  try {
    const response = await axios.get(`${API_URL}/health`, {
      timeout: 2000 // 2 secondes timeout
    });
    
    console.log('\n[Server Check] Response:', {
      status: response.status,
      data: response.data
    });
    
    return response.status === 200;
  } catch (error: any) {
    if (error.code === 'ECONNREFUSED') {
      console.log('\n[Server Check] Connection refused. Vérifiez que le serveur est démarré sur le port 3001');
    } else {
      console.log('\n[Server Check] Error:', error.message);
    }
    return false;
  }
}

// Fonction pour attendre que le serveur soit prêt
async function waitForServer(retries = MAX_RETRIES): Promise<void> {
  for (let i = 0; i < retries; i++) {
    log.info(`Tentative de connexion au serveur (${i + 1}/${MAX_RETRIES})...`);
    
    if (await checkServer()) {
      log.success('Serveur accessible');
      return;
    }
    
    if (i < retries - 1) {
      log.info(`Nouvelle tentative dans ${RETRY_DELAY/1000} seconde...`);
      await new Promise(resolve => setTimeout(resolve, RETRY_DELAY));
    }
  }
  
  const errorMsg = 'Impossible de se connecter au serveur. Vérifiez que:\n' +
    '1. Le serveur est démarré (npm run dev)\n' +
    '2. Le port 3001 est disponible\n' +
    '3. L\'URL est correcte: ' + API_URL;
  
  throw new Error(errorMsg);
}

// Mise à jour des interfaces pour correspondre à la structure exacte
interface FlashOrderResponse {
  data: {
    order: {
      id: string;
      note: string;
      status: string;
      userId: string;
      addressId: string;
      totalAmount: number;
      createdAt: string;
      updatedAt: string;
      user: {
        id: string;
        email: string;
        phone: string | null;
        lastName: string;
        firstName: string;
      };
      address: {
        id: string;
        city: string;
        street: string;
        is_default: boolean;
        postal_code: string;
        gps_latitude: number;
        gps_longitude: number;
      };
    };
    message: string;
  };
}

async function runTest() {
  try {
    log.info('Démarrage du test de commande flash...');

    // Vérifier que le serveur est accessible
    await waitForServer();

    // Vérifier le token
    if (!TEST_DATA.token) {
      throw new Error('Token non fourni');
    }

    // 1. Créer une commande flash
    log.info('Création de la commande flash...');
    const createResponse = await axios.post<FlashOrderResponse>(
      `${API_URL}/orders/flash`,
      {
        addressId: TEST_DATA.addressId,
        notes: "Test de conversion commande flash"
      },
      {
        headers: {
          'Authorization': `Bearer ${TEST_DATA.token}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const orderId = createResponse.data.data.order.id;
    log.success(`Commande flash créée avec ID: ${orderId}`);

    // Vérification du statut initial
    const initialStatus = createResponse.data.data.order.status;
    log.info(`Statut initial: ${initialStatus}`);
    
    if (initialStatus !== 'DRAFT') {
      throw new Error(`Statut initial incorrect: ${initialStatus} (attendu: DRAFT)`);
    }
    log.success('Statut initial correct: DRAFT');

    // 2. Compléter la commande flash
    const completePayload = {
      serviceId: TEST_DATA.serviceId,
      items: TEST_DATA.items.map(item => ({
        articleId: item.articleId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        isPremium: false
      })),
      collectionDate: new Date(Date.now() + 86400000).toISOString(),
      deliveryDate: new Date(Date.now() + 172800000).toISOString(),
    };

    log.info('Conversion de la commande flash en commande normale...');
    log.info(`Payload de conversion: ${JSON.stringify(completePayload, null, 2)}`);

    const completeResponse = await axios.patch<FlashOrderResponse>(
      `${API_URL}/orders/flash/${orderId}/complete`,
      completePayload,
      {
        headers: {
          'Authorization': `Bearer ${TEST_DATA.token}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const completedOrder = completeResponse.data.data.order;
    log.success('Commande convertie avec succès');
    log.info(`Détails de la commande: ${JSON.stringify(completedOrder, null, 2)}`);

    // 3. Vérifications
    const validations = [
      {
        test: completedOrder.status === 'PENDING',
        message: 'Status mis à jour',
        expected: 'PENDING',
        received: completedOrder.status
      },
      {
        test: completedOrder.totalAmount === TEST_DATA.items[0].quantity * TEST_DATA.items[0].unitPrice,
        message: 'Montant calculé',
        expected: TEST_DATA.items[0].quantity * TEST_DATA.items[0].unitPrice,
        received: completedOrder.totalAmount
      }
    ];

    validations.forEach(v => {
      const icon = v.test ? '✅' : '❌';
      log.info(`${icon} ${v.message}:`);
      console.log(`   Attendu: ${v.expected}`);
      console.log(`   Reçu: ${v.received}`);
    });

  } catch (error: any) {
    if (error.response?.data) {
      log.error('Erreur API:', {
        status: error.response.status,
        data: error.response.data,
        headers: error.response.headers,
        requestData: error.response.config?.data
      });
    } else {
      log.error('Erreur:', {
        message: error.message,
        stack: error.stack
      });
    }
    process.exit(1);
  }
}

// Exécuter le test avec gestion des erreurs globale
console.log('\n🚀 Test de commande flash');
console.log('=======================');

runTest().catch(error => {
  log.error('Erreur fatale', error);
  process.exit(1);
});

const axios = require('axios');

const BASE_URL = 'http://localhost:3001';

// Configuration des tests
const config = {
  adminCredentials: {
    email: 'admin@alpha.com',
    password: 'admin123'
  }
};

let adminToken = '';

// Fonction utilitaire pour les logs
function log(message, data = null) {
  console.log(`[TEST] ${message}`);
  if (data) {
    console.log(JSON.stringify(data, null, 2));
  }
}

// Test de connexion admin
async function testAdminLogin() {
  try {
    log('Testing admin login...');
    const response = await axios.post(`${BASE_URL}/api/auth/admin/login`, config.adminCredentials);
    
    if (response.status === 200 && response.data.token) {
      adminToken = response.data.token;
      log('✅ Admin login successful');
      return true;
    } else {
      log('❌ Admin login failed - No token received');
      return false;
    }
  } catch (error) {
    log('❌ Admin login failed', {
      status: error.response?.status,
      message: error.response?.data?.message || error.message
    });
    return false;
  }
}

// Test des endpoints loyalty
async function testLoyaltyEndpoints() {
  const headers = {
    'Authorization': `Bearer ${adminToken}`,
    'Content-Type': 'application/json'
  };

  const tests = [
    {
      name: 'Get Loyalty Stats',
      method: 'GET',
      url: `${BASE_URL}/api/loyalty/admin/stats`
    },
    {
      name: 'Get All Loyalty Points',
      method: 'GET', 
      url: `${BASE_URL}/api/loyalty/admin/points?page=1&limit=5`
    },
    {
      name: 'Get Point Transactions',
      method: 'GET',
      url: `${BASE_URL}/api/loyalty/admin/transactions?page=1&limit=5`
    },
    {
      name: 'Get All Rewards',
      method: 'GET',
      url: `${BASE_URL}/api/loyalty/admin/rewards?page=1&limit=5`
    },
    {
      name: 'Get Reward Claims',
      method: 'GET',
      url: `${BASE_URL}/api/loyalty/admin/claims?page=1&limit=5`
    },
    {
      name: 'Calculate Order Points',
      method: 'POST',
      url: `${BASE_URL}/api/loyalty/calculate-points`,
      data: { orderAmount: 5000 }
    }
  ];

  for (const test of tests) {
    try {
      log(`Testing: ${test.name}...`);
      
      const config = { headers };
      if (test.data) {
        config.data = test.data;
      }

      const response = await axios({
        method: test.method,
        url: test.url,
        ...config
      });

      if (response.status === 200 || response.status === 201) {
        log(`✅ ${test.name} - Success`);
        if (response.data) {
          log(`Response:`, response.data);
        }
      } else {
        log(`⚠️ ${test.name} - Unexpected status: ${response.status}`);
      }
    } catch (error) {
      log(`❌ ${test.name} - Failed`, {
        status: error.response?.status,
        message: error.response?.data?.message || error.message,
        error: error.response?.data?.error
      });
    }
    
    // Pause entre les tests
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}

// Test de santé du serveur
async function testServerHealth() {
  try {
    log('Testing server health...');
    const response = await axios.get(`${BASE_URL}/api/health`);
    
    if (response.status === 200) {
      log('✅ Server is healthy');
      log('Server info:', response.data);
      return true;
    }
  } catch (error) {
    log('❌ Server health check failed', {
      message: error.message
    });
    return false;
  }
}

// Fonction principale
async function runTests() {
  log('='.repeat(50));
  log('STARTING LOYALTY SYSTEM ENDPOINT TESTS');
  log('='.repeat(50));

  // Test de santé du serveur
  const serverHealthy = await testServerHealth();
  if (!serverHealthy) {
    log('❌ Server is not healthy. Stopping tests.');
    return;
  }

  // Test de connexion admin
  const loginSuccess = await testAdminLogin();
  if (!loginSuccess) {
    log('❌ Cannot proceed without admin token. Stopping tests.');
    return;
  }

  // Test des endpoints loyalty
  await testLoyaltyEndpoints();

  log('='.repeat(50));
  log('TESTS COMPLETED');
  log('='.repeat(50));
}

// Exécuter les tests
runTests().catch(error => {
  console.error('Test execution failed:', error);
  process.exit(1);
});
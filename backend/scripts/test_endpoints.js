const axios = require('axios');

// Remplacez ce token par celui que vous avez reçu de get_token.js
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjBjNTMyMzQ4LTFhYWQtNDNlNy05NDgzLTMxNDRjNDI5N2M0NiIsInJvbGUiOiJTVVBFUl9BRE1JTiIsImlhdCI6MTczNDg3Njg2MSwiZXhwIjoxNzM0ODgwNDYxfQ.Rwat6ku3elvb9KIcXSdDnZXbojcxrjgq-4dpe0T1i-8';

const testEndpoints = async () => {
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };

  try {
    console.log('Testing /api/auth/me endpoint...');
    const meResponse = await axios.get('http://localhost:3001/api/auth/me', { headers });
    console.log('Current User:', meResponse.data);

    console.log('\nTesting /api/auth/users endpoint...');
    const usersResponse = await axios.get('http://localhost:3001/api/auth/users', { headers });
    console.log('All Users:', usersResponse.data);

    console.log('\nTesting /api/orders/my-orders endpoint...');
    const myOrdersResponse = await axios.get('http://localhost:3001/api/orders/my-orders', { headers });
    console.log('My Orders:', myOrdersResponse.data);

    console.log('\nTesting /api/orders/all-orders endpoint...');
    const allOrdersResponse = await axios.get('http://localhost:3001/api/orders/all-orders', { headers });
    console.log('All Orders:', allOrdersResponse.data);

    console.log('\nTesting /api/delivery/pending-orders endpoint...');
    const pendingOrdersResponse = await axios.get('http://localhost:3001/api/delivery/pending-orders', { headers });
    console.log('Pending Orders:', pendingOrdersResponse.data);

    console.log('\nTesting /api/delivery/assigned-orders endpoint...');
    const assignedOrdersResponse = await axios.get('http://localhost:3001/api/delivery/assigned-orders', { headers });
    console.log('Assigned Orders:', assignedOrdersResponse.data);

    console.log('\nTesting /api/affiliate/dashboard endpoint...');
    const affiliateDashboardResponse = await axios.get('http://localhost:3001/api/affiliate/dashboard', { headers });
    console.log('Affiliate Dashboard:', affiliateDashboardResponse.data);

    console.log('\nTesting /api/affiliate/commissions endpoint...');
    const affiliateCommissionsResponse = await axios.get('http://localhost:3001/api/affiliate/commissions', { headers });
    console.log('Affiliate Commissions:', affiliateCommissionsResponse.data);

    console.log('\nTesting /api/loyalty/points-balance endpoint...');
    const loyaltyPointsBalanceResponse = await axios.get('http://localhost:3001/api/loyalty/points-balance', { headers });
    console.log('Loyalty Points Balance:', loyaltyPointsBalanceResponse.data);

    console.log('\nTesting /api/notifications/ endpoint...');
    const notificationsResponse = await axios.get('http://localhost:3001/api/notifications/', { headers });
    console.log('Notifications:', notificationsResponse.data);

    console.log('\nTesting /api/services/all endpoint...');
    const allServicesResponse = await axios.get('http://localhost:3001/api/services/all', { headers });
    console.log('All Services:', allServicesResponse.data);

    console.log('\nTesting /api/addresses/all endpoint...');
    const allAddressesResponse = await axios.get('http://localhost:3001/api/addresses/all', { headers });
    console.log('All Addresses:', allAddressesResponse.data);

    console.log('\nTesting /api/orders/:orderId endpoint...');
    const orderId = '8778aba9-30f2-479b-822b-76613fa63821';
    const userId = '0c532348-1aad-43e7-9483-3144c4297c46';
    const orderDetailsResponse = await axios.get(`http://localhost:3001/api/orders/${orderId}`, { headers });
    console.log('Order Details:', orderDetailsResponse.data);

  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
    console.error('Status:', error.response?.status);
    console.error('Headers:', error.response?.headers);
  }
};

testEndpoints();

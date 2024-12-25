const axios = require('axios');

const testEndpoints = async () => {
  try {
    console.log('1. Attempting to login...');
    const loginResponse = await axios.post('http://localhost:3001/api/auth/login', {
      email: 'zasteph300@gmail.com',
      password: 'superadminpassword'
    });

    if (!loginResponse.data || !loginResponse.data.data || !loginResponse.data.data.token) {
      console.error('Login response structure:', loginResponse.data);
      throw new Error('Invalid login response structure');
    }

    const token = loginResponse.data.data.token;
    console.log('2. Token received:', token.substring(0, 20) + '...');

    console.log('3. Testing /me endpoint...');
    const meResponse = await axios.get('http://localhost:3001/api/auth/me', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    console.log('4. Current user data:', meResponse.data);

    console.log('5. Testing service creation...');
    const serviceData = {
      name: 'Washing and Ironing',
      price: 15.00,
      description: 'Washing and ironing service for up to 10 items.'
    };
    const createServiceResponse = await axios.post('http://localhost:3001/api/services/create', serviceData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    console.log('6. Service created:', createServiceResponse.data);

    console.log('7. Testing address creation...');
    const addressData = {
      street: '123 Main St',
      city: 'Anytown',
      postalCode: '12345',
      gpsLatitude: 48.8566,
      gpsLongitude: 2.3522,
      isDefault: true
    };
    const createAddressResponse = await axios.post('http://localhost:3001/api/addresses/create', addressData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    console.log('8. Address created:', createAddressResponse.data);
  } catch (error) {
    console.error('Detailed error information:');
    console.error('Status:', error.response?.status);
    console.error('Status Text:', error.response?.statusText);
    console.error('Error Data:', error.response?.data);
    console.error('Error Message:', error.message);
    if (error.response) {
      console.error('Response Headers:', error.response.headers);
    }
    console.error('Full Error:', error);
  }
};

// Vérifier si le serveur est en cours d'exécution
axios.get('http://localhost:3001')
  .then(() => {
    console.log('Server is running, starting tests...');
    testEndpoints();
  })
  .catch((error) => {
    console.error('Server check failed:', error.message);
    console.error('Please make sure your server is running on port 3001');
  });

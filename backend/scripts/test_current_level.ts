import axios from 'axios';

async function testCurrentLevel() {
  try {
    console.log('Testing current level endpoint...');
    const response = await axios.get('http://localhost:3001/api/affiliate/current-level', {
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImRkNDlmYmJlLWU5ODItNDJhOS1iOGNiLTM1ODMyNDgyNzY5NCIsInJvbGUiOiJBRkZJTElBVEUiLCJpYXQiOjE3MzgzNjA5NTEsImV4cCI6MTczODk2NTc1MX0.HI41KlTyDmVyU9ePa5jWn6QD7hzjCqipUcey4OLULJM'
      }
    });

    console.log('\nResponse:', JSON.stringify(response.data, null, 2));
  } catch (error: any) {
    console.error('\nError:', error.response?.data || error.message);
    console.error('\nStack:', error.stack);
  }
}

testCurrentLevel();
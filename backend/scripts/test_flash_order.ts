import axios from 'axios';

// Données de test
const TEST_DATA = {
  addressId: "03802428-7c13-4e06-b153-bb5a9dde176a",
  token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjBjNTMyMzQ4LTFhYWQtNDNlNy05NDgzLTMxNDRjNDI5N2M0NiIsInJvbGUiOiJTVVBFUl9BRE1JTiIsImlhdCI6MTczODc2NDcwNSwiZXhwIjoxNzM5MzY5NTA1fQ.YYbCsSWNP8o7qvhuW1ueYceYnH1tvq1uxtVd872Ufzk",
  notes: "Commande rapide - chemises à repasser"
};

async function testCreateFlashOrder() {
  try {
    console.log('🚀 Test de création d\'une commande flash...\n');

    // 1. Créer une commande flash via l'API
    console.log('1️⃣  Envoi de la requête POST /orders/flash...');
    
    const response = await axios.post('http://localhost:3001/api/orders/flash', 
      {
        addressId: TEST_DATA.addressId,
        notes: TEST_DATA.notes
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${TEST_DATA.token}`
        }
      }
    );

    console.log('✅ Commande flash créée avec succès !');
    console.log('\nDétails de la commande:');
    console.log(JSON.stringify(response.data.data, null, 2));

    // Vérifier le statut
    const order = response.data.data;
    console.log('\n🔍 Vérification des détails:');
    console.log(`- ID de la commande: ${order.id}`);
    console.log(`- Status: ${order.status} (devrait être DRAFT)`);
    console.log(`- Adresse: ${order.address?.street}, ${order.address?.city}`);
    console.log(`- Client: ${order.user?.firstName} ${order.user?.lastName}`);
    console.log(`- Note: ${order.note || 'Aucune note'}`);

  } catch (error: any) {
    console.error('\n❌ Erreur lors du test:', error.message);
    if (error.response) {
      console.log('\nDétails de l\'erreur:', {
        status: error.response.status,
        statusText: error.response.statusText,
        data: error.response.data
      });
    }
    process.exit(1);
  }
}

// Exécuter le test
testCreateFlashOrder();
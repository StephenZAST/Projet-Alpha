import { config } from 'dotenv';
import path from 'path';
import { createClient } from '@supabase/supabase-js';

// Charger les variables d'environnement depuis le fichier .env
config({ path: path.resolve(__dirname, '../../.env') });

// Créer un client Supabase avec la clé de service pour les tests
const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!,
  {
    auth: {
      persistSession: false
    }
  }
);

import { OrderService } from '../services/order.service/order.service';
import { CreateOrderDTO, Order, OrderItem } from '../models/types';

async function testCreateOrderWithItems() {
  try {
    console.log('\n🚀 Test de création de commande avec items (procédure atomique)');
    console.log('======================================================\n');

    // 1. Préparer les données de test
    const testOrderData = {
      userId: '40c697d7-1104-490c-9d28-f37d696d4a19',
      serviceId: '235d24ef-836d-4e87-aef1-bf028d5d8e3d',
      addressId: '03802428-7c13-4e06-b153-bb5a9dde176a',
      isRecurring: false,
      recurrenceType: 'NONE',
      items: [
        {
          articleId: 'b75ab8ac-58ef-4cdb-b57e-6c8722449cce',
          quantity: 3,
          isPremium: false
        }
      ],
      paymentMethod: 'CASH'
    };

    console.log('📝 Données de test:', testOrderData);

    // 2. Appeler la procédure stockée
    console.log('\n📦 Création de la commande avec la procédure stockée');
    const { data: result, error: procedureError } = await supabase.rpc(
      'create_order_with_items',
      {
        p_userid: testOrderData.userId,
        p_serviceid: testOrderData.serviceId,
        p_addressid: testOrderData.addressId,
        p_isrecurring: testOrderData.isRecurring,
        p_recurrencetype: testOrderData.recurrenceType,
        p_collectiondate: null,
        p_deliverydate: null,
        p_affiliatecode: null,
        p_service_type_id: null,
        p_paymentmethod: testOrderData.paymentMethod,
        p_items: testOrderData.items
      }
    );

    if (procedureError) {
      console.error('❌ Erreur lors de la création:', procedureError);
      throw procedureError;
    }

    console.log('✅ Commande créée avec succès');
    console.log('ID de la commande:', result[0].id);

    // 3. Vérifier les détails de la commande
    console.log('\n🔍 Vérification des détails de la commande');
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select(`
        *,
        items:order_items(
          *,
          article:articles(
            *,
            category:article_categories(*)
          )
        )
      `)
      .eq('id', result[0].id)
      .single();

    if (orderError) {
      console.error('❌ Erreur lors de la récupération de la commande:', orderError);
      throw orderError;
    }

    console.log('\n✅ Détails de la commande:');
    console.log('- ID:', order.id);
    console.log('- Status:', order.status);
    console.log('- Montant total:', order.totalAmount);
    console.log('\n📦 Items de la commande:');
    order.items.forEach((item: any, index: number) => {
      console.log(`\nItem ${index + 1}:`);
      console.log('- Article:', item.article.name);
      console.log('- Catégorie:', item.article.category?.name);
      console.log('- Quantité:', item.quantity);
      console.log('- Prix unitaire:', item.unitPrice);
    });

    // 4. Vérifier que le montant total est correct
    const expectedTotal = order.items.reduce((sum: number, item: any) => {
      return sum + (item.quantity * item.unitPrice);
    }, 0);

    if (order.totalAmount !== expectedTotal) {
      throw new Error(`Le montant total ne correspond pas. Attendu: ${expectedTotal}, Reçu: ${order.totalAmount}`);
    }

    console.log('\n✅ Montant total vérifié et correct');

    // 5. Nettoyage
    console.log('\n🧹 Nettoyage des données de test');
    
    const { error: deleteItemsError } = await supabase
      .from('order_items')
      .delete()
      .eq('orderId', order.id);

    if (deleteItemsError) {
      console.error('❌ Erreur lors de la suppression des items:', deleteItemsError);
      throw deleteItemsError;
    }

    const { error: deleteOrderError } = await supabase
      .from('orders')
      .delete()
      .eq('id', order.id);

    if (deleteOrderError) {
      console.error('❌ Erreur lors de la suppression de la commande:', deleteOrderError);
      throw deleteOrderError;
    }

    console.log('✅ Données de test nettoyées avec succès');
    console.log('\n✨ Test terminé avec succès ✨');

  } catch (error) {
    console.error('\n❌ Erreur pendant le test:', error);
    throw error;
  }
}

// Exécuter les tests
async function runTests() {
  try {
    await testCreateOrderWithItems();
    console.log('\n✅ Tous les tests ont réussi');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Échec des tests:', error);
    process.exit(1);
  }
}

runTests();
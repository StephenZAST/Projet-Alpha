import { config } from 'dotenv';
import path from 'path';
import { createClient } from '@supabase/supabase-js';

// Charger les variables d'environnement depuis le fichier .env
config({ path: path.resolve(__dirname, '../../.env') });

// Créer un client Supabase avec la clé de service pour les tests
const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!, // Utiliser la clé de service au lieu de la clé anonyme
  {
    auth: {
      persistSession: false
    }
  }
);
import { OrderService } from '../services/order.service';
import { CreateOrderDTO, Order, OrderItem } from '../models/types';

// Charger les variables d'environnement depuis le fichier .env
config({ path: path.resolve(__dirname, '../../.env') });

// Vérifier la connexion à Supabase avant de commencer les tests
async function checkSupabaseConnection() {
  try {
    console.log('\n🔑 Note importante:');
    console.log('Pour que ce test fonctionne, assurez-vous que:');
    console.log('1. RLS est activé pour la table orders');
    console.log('2. Une politique est créée pour permettre l\'insertion (enable_row_level_security)');
    console.log('3. La politique doit autoriser les opérations INSERT/SELECT\n');

    const { data, error } = await supabase
      .from('orders')
      .select('id')
      .limit(1);

    if (error) {
      if (error.message.includes('policy')) {
        throw new Error('Erreur de politique RLS. Vérifiez les permissions de la table orders.');
      }
      throw error;
    }

    console.log('✅ Connexion Supabase établie avec succès');
    return true;
  } catch (error) {
    console.error('❌ Erreur de connexion à Supabase:', error);
    return false;
  }
}

async function testOrderItemInsertion() {
  try {
    // Vérifier la connexion à Supabase
    const isConnected = await checkSupabaseConnection();
    if (!isConnected) {
      throw new Error('Impossible de continuer les tests sans connexion à Supabase');
    }

    console.log('\n🚀 Démarrage des tests d\'insertion des items de commande');
    console.log('================================================\n');

    // 1. Créer une commande de test
    const testOrderData: CreateOrderDTO = {
      userId: '40c697d7-1104-490c-9d28-f37d696d4a19',
      serviceId: '235d24ef-836d-4e87-aef1-bf028d5d8e3d',
      addressId: '03802428-7c13-4e06-b153-bb5a9dde176a',
      isRecurring: false,
      recurrenceType: 'NONE',
      items: [
        {
          articleId: 'b75ab8ac-58ef-4cdb-b57e-6c8722449cce',
          quantity: 3,
          premiumPrice: false
        }
      ],
      paymentMethod: 'CASH'
    };

    console.log('📝 Données de test:', {
      userId: testOrderData.userId,
      serviceId: testOrderData.serviceId,
      items: testOrderData.items
    });

    // 2. Test d'insertion directe d'un item
    console.log('\n📦 Création de la commande de test');
    console.log('--------------------------------');
    console.log('Tentative de création de la commande avec les données:', testOrderData);
    
    const orderToCreate = {
      userId: testOrderData.userId,               // En camelCase comme dans la BD
      serviceId: testOrderData.serviceId,         // En camelCase comme dans la BD
      addressId: testOrderData.addressId,         // En camelCase comme dans la BD
      status: 'PENDING',                          // order_status enum
      isRecurring: false,
      recurrenceType: 'NONE',                     // recurrence_type enum
      totalAmount: 0,
      paymentMethod: 'CASH',                      // payment_method_enum
      service_type_id: null,                      // Garder en snake_case car c'est comme ça dans la BD
      collectionDate: null,                       // timestamptz
      deliveryDate: null,                         // timestamptz
      nextRecurrenceDate: null,                   // timestamptz
      affiliateCode: null                         // Pas besoin d'envoyer createdAt/updatedAt, ils sont gérés par la BD
    };

    console.log('\n📋 Détails de la commande à créer:', JSON.stringify(orderToCreate, null, 2));

    // Vérifier l'existence des relations avant l'insertion
    console.log('\n🔍 Vérification des relations...');
    
    const { data: addressCheck, error: addressError } = await supabase
      .from('addresses')
      .select('*')
      .eq('id', orderToCreate.addressId)
      .single();

    if (addressError || !addressCheck) {
      console.error('❌ Erreur: Adresse non trouvée');
      throw new Error(`L'adresse ${orderToCreate.addressId} n'existe pas`);
    }
    console.log('✅ Adresse trouvée');

    // Tenter l'insertion avec tous les détails
    console.log('\n📝 Tentative d\'insertion de la commande...');
    const { data: order, error: createError } = await supabase
      .from('orders')
      .insert([orderToCreate])
      .select(`
        *,
        service:services(*),
        address:addresses(*)
      `)
      .single();

    if (createError) {
      console.error('\n❌ Erreur détaillée:', {
        code: createError.code,
        message: createError.message,
        details: createError.details,
        hint: createError.hint
      });

      // Vérifications supplémentaires en cas d'erreur
      console.log('\n🔍 Vérifications de débogage:');
      Object.entries(orderToCreate).forEach(([key, value]) => {
        console.log(`   ${key}: ${typeof value} = ${JSON.stringify(value)}`);
      });
      
      throw new Error(`Échec de la création de la commande: ${createError.message}`);
    }

    if (!order) {
      throw new Error('Aucune donnée retournée après la création');
    }

    console.log('\n✅ Commande créée avec succès:', {
      id: order.id,
      status: order.status,
      service: order.service?.name,
      address: order.address?.street,
      totalAmount: order.totalAmount
    });

    console.log('✅ Commande de test créée:', order.id);

    // 3. Tester la récupération de l'article
    console.log('\n🔍 Test de récupération de l\'article');
    console.log('--------------------------------');
    const { data: article } = await supabase
      .from('articles')
      .select('*, category:article_categories(*)')
      .eq('id', testOrderData.items[0].articleId)
      .single();

    if (!article) {
      throw new Error('Article non trouvé');
    }

    console.log('✅ Article trouvé:', {
      id: article.id,
      name: article.name,
      price: article.basePrice,
      category: article.category?.name
    });

    // 4. Tester l'insertion de l'item
    console.log('\n📝 Test d\'insertion de l\'item de commande');
    console.log('------------------------------------');

    // Vérifier que l'article et le prix sont valides
    if (!article.basePrice || isNaN(article.basePrice)) {
      throw new Error(`Prix de base invalide pour l'article ${article.id}: ${article.basePrice}`);
    }

    const orderItem = {
      orderId: order.id,
      articleId: testOrderData.items[0].articleId,
      serviceId: testOrderData.serviceId,
      quantity: testOrderData.items[0].quantity,
      unitPrice: article.basePrice,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    console.log('Données de l\'item à insérer:', {
      ...orderItem,
      articleName: article.name,
      articlePrice: article.basePrice
    });

    // Tentative d'insertion avec gestion détaillée des erreurs
    let insertedItem;
    try {
      const { data, error } = await supabase
        .from('order_items')
        .insert([orderItem])
        .select(`
          *,
          article:articles(
            *,
            category:article_categories(*)
          )
        `)
        .single();

      if (error) {
        console.error('❌ Erreur lors de l\'insertion:', error);
        if (error.code === '23503') {
          console.error('Erreur de clé étrangère - Vérifiez les IDs de référence');
        }
        throw error;
      }

      if (!data) {
        throw new Error('Aucune donnée retournée après l\'insertion');
      }

      insertedItem = data;
      console.log('✅ Item inséré avec succès');
    } catch (error) {
      console.error('❌ Échec de l\'insertion:', error);
      throw error;
    }

    // 5. Vérifier la récupération de l'item
    console.log('\n🔍 Vérification de la récupération des items');
    console.log('----------------------------------------');

    const { data: fetchedItems, error: fetchError } = await supabase
      .from('order_items')
      .select(`
        *,
        article:articles(
          *,
          category:article_categories(*)
        )
      `)
      .eq('orderId', order.id);

    if (fetchError) {
      console.error('❌ Erreur lors de la récupération des items:', fetchError);
      throw fetchError;
    }

    if (!fetchedItems || fetchedItems.length === 0) {
      console.error('❌ Aucun item trouvé pour la commande:', order.id);
      throw new Error('Items non trouvés après insertion');
    }

    console.log('✅ Nombre d\'items récupérés:', fetchedItems.length);
    console.log('\nDétails des items récupérés:');
    fetchedItems.forEach((item, index) => {
      console.log(`\nItem ${index + 1}:`);
      console.log('- ID:', item.id);
      console.log('- Article:', item.article.name);
      console.log('- Catégorie:', item.article.category?.name);
      console.log('- Quantité:', item.quantity);
      console.log('- Prix unitaire:', item.unitPrice);
    });

    // Vérification supplémentaire des données
    const insertedItemData = fetchedItems[0];
    if (
      insertedItemData.quantity !== orderItem.quantity ||
      insertedItemData.unitPrice !== orderItem.unitPrice ||
      insertedItemData.articleId !== orderItem.articleId
    ) {
      console.error('❌ Incohérence dans les données insérées vs récupérées:');
      console.error('Données insérées:', orderItem);
      console.error('Données récupérées:', insertedItemData);
      throw new Error('Incohérence dans les données des items');
    }

    console.log('\n✅ Vérification des données réussie - Les données correspondent');

    // 6. Nettoyage
    console.log('\n🧹 Nettoyage des données de test');
    console.log('------------------------------');
    
    try {
      // Supprimer d'abord les items de commande
      const { error: deleteItemsError } = await supabase
        .from('order_items')
        .delete()
        .eq('orderId', order.id);
      
      if (deleteItemsError) {
        console.error('❌ Erreur lors de la suppression des items:', deleteItemsError);
        throw deleteItemsError;
      }
      
      // Puis supprimer la commande
      const { error: deleteOrderError } = await supabase
        .from('orders')
        .delete()
        .eq('id', order.id);
      
      if (deleteOrderError) {
        console.error('❌ Erreur lors de la suppression de la commande:', deleteOrderError);
        throw deleteOrderError;
      }
      
      console.log('✅ Données de test nettoyées avec succès');
    } catch (cleanupError) {
      console.error('❌ Erreur lors du nettoyage:', cleanupError);
      throw cleanupError;
    }

    console.log('\n✨ Test terminé avec succès ✨');
  } catch (error) {
    console.error('\n❌ Erreur pendant le test:', error);
    throw error;
  }
}

// Fonction principale d'exécution
async function runTests() {
  console.log('\n🔧 Configuration du test');
  console.log('=====================');
  
  try {
    await testOrderItemInsertion();
    console.log('\n✅ Tous les tests ont réussi');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Échec des tests:', error);
    process.exit(1);
  }
}

// Exécuter les tests
runTests();
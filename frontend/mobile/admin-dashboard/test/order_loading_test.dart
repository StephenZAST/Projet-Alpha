import 'package:admin/services/auth_service.dart';
import 'package:admin/services/order_service.dart';

// Données d'authentification admin
const TEST_CREDENTIALS = {
  'email': 'newemail@example.com',
  'password': 'password123'
};

Future<void> main() async {
  print('🚀 Démarrage des tests de chargement des commandes...\n');

  try {
    // 1. Authentification
    print('1️⃣ Authentification...');
    final authResponse = await AuthService.login(
        TEST_CREDENTIALS['email']!, TEST_CREDENTIALS['password']!);

    if (!authResponse['success']) {
      throw 'Échec de l\'authentification: ${authResponse['message']}';
    }
    print('✅ Authentification réussie\n');

    // 2. Test du chargement des commandes
    print('2️⃣ Chargement des commandes...');
    final ordersPage = await OrderService.loadOrdersPage();
    print('Commandes chargées: ${ordersPage.orders.length}');

    // Analyse des statuts
    final statusCount = <String, int>{};
    for (var order in ordersPage.orders) {
      statusCount[order.status] = (statusCount[order.status] ?? 0) + 1;
      print('- ${order.id}: ${order.status} (Flash: ${order.isFlashOrder})');
    }

    print('\nRépartition par statut:');
    statusCount.forEach((status, count) {
      print('$status: $count commandes');
    });

    // 3. Test des commandes flash
    print('\n3️⃣ Chargement des commandes flash...');
    final draftOrders = await OrderService.getDraftOrders();
    print('Commandes flash trouvées: ${draftOrders.length}');
    for (var order in draftOrders) {
      print('- ${order.id}: ${order.status} (Notes: ${order.notes})');
    }

    // 4. Test des commandes récentes
    print('\n4️⃣ Chargement des commandes récentes...');
    final recentOrders = await OrderService.getRecentOrders();
    print('Commandes récentes: ${recentOrders.length}');
    for (var order in recentOrders) {
      print('- ${order.id}: ${order.status} (${order.createdAt})');
    }

    print('\n✅ Tests terminés avec succès!');
  } catch (e, stack) {
    print('\n❌ Erreur pendant les tests:');
    print('Error: $e');
    print('Stack trace: $stack');
  }
}

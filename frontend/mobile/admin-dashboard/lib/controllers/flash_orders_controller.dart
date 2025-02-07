import 'package:get/get.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class FlashOrdersController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final draftOrders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDraftOrders();
  }

  Future<void> loadDraftOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final orders = await OrderService.getDraftOrders();
      if (orders.isEmpty) {
        print('[FlashOrdersController] No draft orders found');
      } else {
        print('[FlashOrdersController] Loaded ${orders.length} draft orders');
      }

      draftOrders.clear(); // Clear before adding new items
      draftOrders.addAll(orders);
    } catch (e) {
      print('[FlashOrdersController] Error loading draft orders: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des commandes flash';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() => loadDraftOrders();
}

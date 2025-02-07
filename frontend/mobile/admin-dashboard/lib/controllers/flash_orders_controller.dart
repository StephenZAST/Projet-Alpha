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
      draftOrders.assignAll(orders);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des commandes flash';
      print('[FlashOrdersController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() => loadDraftOrders();
}

import 'package:get/get.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class FlashOrdersController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final draftOrders = <Order>[].obs;
  
  // Pagination state
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  final itemsPerPage = 20.obs;
  final isLoadingPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDraftOrders();
  }

  Future<void> loadDraftOrders({int? page}) async {
    try {
      final pageToLoad = page ?? currentPage.value;
      
      if (pageToLoad == 1) {
        isLoading.value = true;
        draftOrders.clear();
      } else {
        isLoadingPage.value = true;
      }
      
      hasError.value = false;
      errorMessage.value = '';

      // Utiliser la pagination avec le filtre isFlashOrder
      final result = await OrderService.loadOrdersPage(
        page: pageToLoad,
        limit: itemsPerPage.value,
        isFlashOrder: true,
        sortField: 'createdAt',
        sortOrder: 'desc',
      );

      if (result.orders.isEmpty && pageToLoad == 1) {
        print('[FlashOrdersController] No flash orders found');
      } else {
        print('[FlashOrdersController] Loaded ${result.orders.length} flash orders for page $pageToLoad');
      }

      // Mettre à jour les données de pagination
      currentPage.value = pageToLoad;
      totalPages.value = result.totalPages;
      totalItems.value = result.total;

      if (pageToLoad == 1) {
        draftOrders.assignAll(result.orders);
      } else {
        draftOrders.addAll(result.orders);
      }
    } catch (e) {
      print('[FlashOrdersController] Error loading flash orders: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des commandes flash';
    } finally {
      isLoading.value = false;
      isLoadingPage.value = false;
    }
  }

  Future<void> refreshOrders() async {
    currentPage.value = 1;
    await loadDraftOrders(page: 1);
  }

  Future<void> loadNextPage() async {
    if (currentPage.value < totalPages.value && !isLoadingPage.value) {
      await loadDraftOrders(page: currentPage.value + 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      draftOrders.clear();
      await loadDraftOrders(page: page);
    }
  }

  bool get hasNextPage => currentPage.value < totalPages.value;
  bool get hasPreviousPage => currentPage.value > 1;
  
  String get paginationInfo {
    if (totalItems.value == 0) return 'Aucun élément';
    
    final start = (currentPage.value - 1) * itemsPerPage.value + 1;
    final end = (currentPage.value * itemsPerPage.value).clamp(0, totalItems.value);
    
    return '$start-$end sur ${totalItems.value}';
  }
}

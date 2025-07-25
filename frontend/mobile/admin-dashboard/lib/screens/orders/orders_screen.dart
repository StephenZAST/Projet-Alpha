import 'package:admin/screens/orders/components/advanced_search_filter.dart';
import 'package:admin/widgets/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import '../../models/enums.dart' hide AppButtonVariant;
import '../../widgets/shared/app_button.dart';
import 'components/order_filters.dart';
import 'components/orders_header.dart';
import 'components/orders_table.dart';
import 'components/order_details_dialog.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    controller.loadOrdersPage(status: controller.filterStatus.value);
  }

  void _updateStatus(String orderId, OrderStatus newStatus) {
    controller.updateOrderStatus(orderId, newStatus);
  }

  void _handleOrderSelect(String orderId) {
    controller.fetchOrderDetails(orderId);
    final order = controller.orders.firstWhereOrNull((o) => o.id == orderId) ??
        controller.selectedOrder.value;
    if (order != null) {
      Get.dialog(
        Dialog(
          child: Container(
            width: 800,
            padding: EdgeInsets.all(defaultPadding),
            child: OrderDetailsDialog(order: order),
          ),
        ),
      );
    } else {
      Get.rawSnackbar(
        messageText: Text('Commande non trouvée.'),
        backgroundColor: Colors.red,
        borderRadius: 12,
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    }
  }

  Widget _buildPaginationControls() {
    // Guards et auto-fix pour la pagination
    final currentPage =
        controller.currentPage.value < 1 ? 1 : controller.currentPage.value;
    final totalPages =
        controller.totalPages.value < 1 ? 1 : controller.totalPages.value;
    final itemsPerPage =
        controller.itemsPerPage.value < 1 ? 10 : controller.itemsPerPage.value;
    final itemCount =
        controller.orders.length < 0 ? 0 : controller.orders.length;
    final totalItems =
        controller.totalOrders.value < 0 ? 0 : controller.totalOrders.value;

    // Si la pagination est incohérente (page courante > totalPages), auto-fix ou affiche une erreur
    if (currentPage > totalPages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.currentPage.value = totalPages;
        controller.loadOrdersPage(
          page: totalPages,
          status: controller.filterStatus.value,
        );
      });
      return Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Text(
              'Pagination incohérente : page $currentPage > $totalPages. Correction automatique...',
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            AppButton(
              label: 'Réinitialiser',
              icon: Icons.refresh,
              onPressed: () => controller.loadOrdersPage(
                  page: 1, status: controller.filterStatus.value),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      );
    }
    try {
      return Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: PaginationControls(
          currentPage: currentPage,
          totalPages: totalPages,
          itemCount: itemCount,
          totalItems: totalItems,
          itemsPerPage: itemsPerPage,
          onPrevious: () => controller.loadOrdersPage(
            page: currentPage > 1 ? currentPage - 1 : 1,
            status: controller.filterStatus.value,
          ),
          onNext: () => controller.loadOrdersPage(
            page: currentPage < totalPages ? currentPage + 1 : totalPages,
            status: controller.filterStatus.value,
          ),
          onItemsPerPageChanged: (value) {
            if (value != null && value > 0) {
              controller.setItemsPerPage(value);
              controller.loadOrdersPage(
                page: 1,
                status: controller.filterStatus.value,
                limit: value,
              );
            }
          },
          onPageChanged: (page) {
            if (page != null && page != currentPage) {
              controller.currentPage.value = page;
              controller.loadOrdersPage(
                  page: page, status: controller.filterStatus.value);
            }
          },
        ),
      );
    } catch (e, stack) {
      print('[PaginationControls][ERROR] $e\n$stack');
      return Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Text('Erreur de pagination: $e',
            style: TextStyle(color: Colors.red)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrdersHeader(),
                SizedBox(height: defaultPadding),
                AdvancedSearchFilter(),
                SizedBox(height: defaultPadding),
                OrderFilters(),
                SizedBox(height: defaultPadding),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Card(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        );
                      }

                      if (controller.hasError.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.error,
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                controller.errorMessage.value,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              AppButton(
                                label: 'Réessayer',
                                icon: Icons.refresh_outlined,
                                onPressed: controller.loadOrdersPage,
                                variant: AppButtonVariant.primary,
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.orders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 48,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textLight
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'Aucune commande trouvée',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.textLight
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Column(
                          children: [
                            Expanded(
                              child: OrdersTable(
                                orders: controller.orders,
                                onStatusUpdate: _updateStatus,
                                onOrderSelect: _handleOrderSelect,
                              ),
                            ),
                            // Ajout pagination locale juste en dessous de OrdersTable
                            Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: PaginationControls(
                                currentPage: controller.currentPage.value,
                                totalPages: controller.totalPages.value,
                                itemCount: controller.orders.length,
                                totalItems: controller.totalOrders.value,
                                itemsPerPage: controller.itemsPerPage.value,
                                onPrevious: controller.previousPage,
                                onNext: controller.nextPage,
                                onItemsPerPageChanged: (value) {
                                  if (value != null && value > 0) {
                                    controller.setItemsPerPage(value);
                                  }
                                },
                                onPageChanged: (page) {
                                  if (page != null &&
                                      page != controller.currentPage.value) {
                                    controller.currentPage.value = page;
                                    controller.loadOrdersPage(page: page);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

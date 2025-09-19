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

  Future<void> _handleOrderSelect(String orderId) async {
    await controller.fetchOrderDetails(orderId);
    final order = controller.selectedOrder.value;
    if (order != null && order.id == orderId) {
      Get.dialog(
        Dialog(
          child: Container(
            width: 800,
            padding: EdgeInsets.all(defaultPadding),
            child: OrderDetailsDialog(orderId: orderId),
          ),
        ),
      );
    } else {
      // Optionnel : affiche une erreur ou un toast si l'order n'est pas prêt
      Get.snackbar(
          'Erreur', 'Impossible de charger les détails de la commande.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header fixe
              OrdersHeader(),
              SizedBox(height: defaultPadding),
              
              // Zone scrollable pour les filtres et le tableau
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Filtres dans un SliverToBoxAdapter
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          AdvancedSearchFilter(),
                          SizedBox(height: defaultPadding),
                          OrderFilters(),
                          SizedBox(height: defaultPadding),
                        ],
                      ),
                    ),
                    
                    // Tableau dans un SliverFillRemaining
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Card(
                        elevation: 0,
                        color: Colors.transparent,
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
                                    color: isDark
                                        ? AppColors.textLight
                                        : AppColors.textSecondary,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Aucune commande trouvée',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textLight
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Tableau avec hauteur flexible
                              Expanded(
                                child: Obx(() {
                                  if (controller.isOrderIdSearchActive.value &&
                                      controller.orderIdResult.value != null) {
                                    return OrdersTable(
                                      orders: [controller.orderIdResult.value!],
                                      onStatusUpdate: _updateStatus,
                                      onOrderSelect: _handleOrderSelect,
                                    );
                                  } else {
                                    return OrdersTable(
                                      orders: controller.orders,
                                      onStatusUpdate: _updateStatus,
                                      onOrderSelect: _handleOrderSelect,
                                    );
                                  }
                                }),
                              ),
                              
                              // Pagination fixe en bas
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                  horizontal: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? AppColors.gray800.withOpacity(0.5)
                                      : AppColors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(AppRadius.md),
                                    bottomRight: Radius.circular(AppRadius.md),
                                  ),
                                ),
                                child: Obx(() => PaginationControls(
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
                                )),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

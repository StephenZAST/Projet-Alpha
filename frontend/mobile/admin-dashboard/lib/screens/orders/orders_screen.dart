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
import 'components/order_details.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    controller.fetchOrders();
  }

  void _updateStatus(String orderId, OrderStatus newStatus) {
    controller.updateOrderStatus(orderId, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrdersHeader(),
              SizedBox(height: defaultPadding),
              OrderFilters(),
              SizedBox(height: defaultPadding),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                              onPressed: controller.fetchOrders,
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
                        Expanded(
                          child: OrdersTable(
                            orders: controller.orders,
                            onStatusUpdate: _updateStatus,
                            onOrderSelect: (orderId) {
                              controller.fetchOrderDetails(orderId);
                              Get.dialog(
                                Dialog(
                                  child: Container(
                                    width: 800,
                                    padding: EdgeInsets.all(defaultPadding),
                                    child: OrderDetails(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(defaultPadding),
                          child: PaginationControls(
                            currentPage: controller.currentPage.value,
                            totalPages: controller.totalPages.value,
                            itemsPerPage: controller.itemsPerPage.value,
                            totalItems: controller.totalOrders.value,
                            onNextPage: controller.nextPage,
                            onPreviousPage: controller.previousPage,
                            onItemsPerPageChanged: controller.setItemsPerPage,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

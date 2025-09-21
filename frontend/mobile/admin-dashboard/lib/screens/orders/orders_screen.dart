import 'package:admin/screens/orders/components/advanced_search_filter.dart';
import 'package:admin/widgets/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import '../../models/enums.dart' hide AppButtonVariant;
import '../../widgets/shared/app_button.dart';
import 'components/orders_header.dart';
import 'components/simple_orders_table.dart';
import 'components/order_details_dialog.dart';
import 'components/orders_map_view.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    // Force le rechargement des données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceReloadData();
    });
  }

  void _forceReloadData() async {
    print('[OrdersScreen] Force reload data...');
    try {
      // Reset des états
      controller.isLoading.value = true;
      controller.hasError.value = false;
      controller.errorMessage.value = '';

      // Chargement des données
      await controller.loadOrdersPage(
        page: 1,
        limit: controller.itemsPerPage.value,
        status: controller.filterStatus.value,
      );

      print(
          '[OrdersScreen] Data loaded successfully. Orders count: ${controller.orders.length}');
    } catch (e) {
      print('[OrdersScreen] Error loading data: $e');
      controller.hasError.value = true;
      controller.errorMessage.value = 'Erreur lors du chargement: $e';
    } finally {
      controller.isLoading.value = false;
    }
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

              // Zone principale avec vue dynamique
              Expanded(
                child: Obx(() {
                  // Afficher la vue selon la sélection
                  switch (controller.currentView.value) {
                    case OrderView.map:
                      return OrdersMapView();
                    case OrderView.cards:
                      return _buildCardsView(isDark);
                    case OrderView.table:
                    default:
                      return _buildTableView(isDark);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableView(bool isDark) {
    return CustomScrollView(
      slivers: [
        // Filtres dans un SliverToBoxAdapter
        SliverToBoxAdapter(
          child: Column(
            children: [
              AdvancedSearchFilter(),
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
              // Debug: Afficher l'état du controller
              print(
                  '[OrdersScreen] isLoading: ${controller.isLoading.value}');
              print(
                  '[OrdersScreen] hasError: ${controller.hasError.value}');
              print(
                  '[OrdersScreen] orders.length: ${controller.orders.length}');
              print(
                  '[OrdersScreen] isOrderIdSearchActive: ${controller.isOrderIdSearchActive.value}');

              if (controller.isLoading.value) {
                return Container(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Chargement des commandes...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.hasError.value) {
                return Container(
                  height: 400,
                  child: Center(
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
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: 'Réessayer',
                          icon: Icons.refresh_outlined,
                          onPressed: () =>
                              controller.loadOrdersPage(),
                          variant: AppButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Vérifier si on a des données à afficher
              final ordersToShow =
                  controller.isOrderIdSearchActive.value &&
                          controller.orderIdResult.value != null
                      ? [controller.orderIdResult.value!]
                      : controller.orders;

              if (ordersToShow.isEmpty) {
                return Container(
                  height: 400,
                  child: Center(
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
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Essayez de modifier vos filtres ou créez une nouvelle commande',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Afficher le tableau avec les données
              return Column(
                children: [
                  // Tableau simple et robuste
                  SimpleOrdersTable(
                    orders: ordersToShow,
                    onStatusUpdate: _updateStatus,
                    onOrderSelect: _handleOrderSelect,
                  ),

                  // Pagination fixe en bas (seulement si pas de recherche par ID)
                  if (!controller.isOrderIdSearchActive.value)
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
                          bottomRight:
                              Radius.circular(AppRadius.md),
                        ),
                      ),
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
                              page !=
                                  controller.currentPage.value) {
                            controller.currentPage.value = page;
                            controller.loadOrdersPage(page: page);
                          }
                        },
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_module,
            size: 64,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Vue en cartes',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Cette vue sera bientôt disponible',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/providers/order_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/order/order_status_filter.dart';
import 'package:prima/widgets/order/orders_list.dart';
import 'package:prima/widgets/connection_error_widget.dart';
import 'package:prima/widgets/refresh/custom_refresh_indicator.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => context.read<OrderProvider>().loadOrders());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrderProvider>().loadOrders();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppBarComponent(
              title: 'Mes Commandes',
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Consumer<OrderProvider>(
              builder: (context, provider, _) => OrderStatusFilter(
                selectedStatus: provider.selectedFilter,
                onStatusSelected: provider.setStatusFilter,
              ),
            ),
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: () =>
                    context.read<OrderProvider>().loadOrders(refresh: true),
                child: Consumer<OrderProvider>(
                  builder: (context, provider, _) {
                    if (provider.isFirstLoad && provider.isLoading) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (provider.error != null) {
                      return ConnectionErrorWidget(
                        onRetry: () => provider.loadOrders(refresh: true),
                        customMessage: 'Impossible de charger vos commandes',
                      );
                    }

                    return OrdersList(
                      orders: provider.filteredOrders,
                      scrollController: _scrollController,
                      isLoading: provider.isLoading,
                      hasMore: provider.hasMore,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import '../../widgets/loading_overlay.dart';
import 'components/orders_header.dart';
import 'components/order_filters.dart';
import 'components/orders_table.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return SafeArea(
      child: LoadingOverlay(
        isLoading: controller.isLoading.value,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              OrdersHeader(),
              SizedBox(height: defaultPadding),
              OrderFilters(),
              SizedBox(height: defaultPadding),
              Obx(() => OrdersTable(
                    orders: controller.orders,
                    onStatusUpdate: (orderId, newStatus) =>
                        controller.updateOrderStatus(orderId, newStatus),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import 'components/orders_header.dart';
import 'components/order_filters.dart';
import 'components/orders_table.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            OrdersHeader(),
            SizedBox(height: defaultPadding),
            OrderFilters(),
            SizedBox(height: defaultPadding),
            Obx(
              () => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : OrdersTable(orders: controller.filteredOrders),
            ),
          ],
        ),
      ),
    );
  }
}

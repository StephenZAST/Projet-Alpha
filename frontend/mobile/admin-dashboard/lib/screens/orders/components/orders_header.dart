import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';

class OrdersHeader extends StatelessWidget {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search orders...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: controller.searchOrders,
          ),
        ),
        SizedBox(width: defaultPadding),
        ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: defaultPadding * 1.5,
              vertical: defaultPadding,
            ),
          ),
          onPressed: () => Get.toNamed('/orders/create'),
          icon: Icon(Icons.add),
          label: Text("Add New Order"),
        ),
      ],
    );
  }
}

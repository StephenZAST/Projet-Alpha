import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';

class OrderFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search orders...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => controller.searchOrders(value),
            ),
          ),
          SizedBox(width: defaultPadding),
          DropdownButton<String>(
            value: controller.selectedStatus.value?.label,
            items: ['Tous', ...OrderStatus.values.map((status) => status.label)]
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {
              controller.updateStatusFilter(
                OrderStatus.values
                    .firstWhere((status) => status.label == value),
              );
            },
          ),
        ],
      ),
    );
  }
}

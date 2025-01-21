import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';

class OrdersHeader extends StatelessWidget {
  final searchController = TextEditingController();
  final OrdersController orderController = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Orders",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Spacer(),
            _buildExportButton(),
            SizedBox(width: defaultPadding),
            _buildFilterButton(),
            SizedBox(width: defaultPadding),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical: defaultPadding / 2,
                ),
              ),
              onPressed: () => _showAddOrderDialog(context),
              icon: Icon(Icons.add),
              label: Text("Add Order"),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: "Search orders...",
        fillColor: AppColors.secondaryBg,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) => orderController.searchOrders(value),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<OrderStatus>(
      icon: Icon(Icons.filter_list),
      onSelected: (status) => orderController.updateStatusFilter(status),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Text('All Orders'),
        ),
        ...OrderStatus.values.map(
          (status) => PopupMenuItem(
            value: status,
            child: Text(status.label),
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return IconButton(
      icon: Icon(Icons.download),
      onPressed: () => _showExportDialog(),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Export Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Export as PDF'),
              onTap: () {
                orderController.exportOrders(ExportType.PDF);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Export as Excel'),
              onTap: () {
                orderController.exportOrders(ExportType.EXCEL);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOrderDialog(BuildContext context) {
    // TODO: Implement add order dialog
    Get.toNamed('/orders/create');
  }
}

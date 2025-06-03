import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import 'components/order_stepper.dart';

class NewOrderScreen extends StatelessWidget {
  final OrdersController controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouvelle Commande',
          style: AppTextStyles.h3,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Card(
          child: OrderStepper(),
        ),
      ),
    );
  }
}

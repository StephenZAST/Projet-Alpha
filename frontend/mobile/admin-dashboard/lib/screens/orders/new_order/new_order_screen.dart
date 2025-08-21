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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Abandonner / Réinitialiser',
            onPressed: () {
              controller.resetOrderStepper();
              Get.snackbar('Commande réinitialisée',
                  'Le formulaire a été remis à zéro.');
            },
          ),
        ],
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import 'steps/client_selection_step.dart';
import 'steps/service_selection_step.dart';
import 'steps/articles_selection_step.dart';
import 'steps/order_summary_step.dart';

class OrderStepper extends StatelessWidget {
  final controller = Get.find<OrdersController>();
  final currentStep = 0.obs;

  final steps = [
    'Sélection du client',
    'Service',
    'Articles',
    'Récapitulatif',
  ];

  Widget _buildStep(int index) {
    switch (index) {
      case 0:
        return ClientSelectionStep();
      case 1:
        return ServiceSelectionStep();
      case 2:
        return ArticlesSelectionStep();
      case 3:
        return OrderSummaryStep();
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() => _buildStep(currentStep.value)),
        ),
        _buildStepperControls(context),
      ],
    );
  }

  Widget _buildStepperControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              if (currentStep.value > 0) {
                currentStep.value--;
              } else {
                Get.back();
              }
            },
            child: Text('Retour'),
          ),
          ElevatedButton(
            onPressed: () {
              if (currentStep.value < steps.length - 1) {
                currentStep.value++;
              } else {
                // Soumettre la commande
                _submitOrder();
              }
            },
            child: Text(currentStep.value < steps.length - 1
                ? 'Suivant'
                : 'Créer la commande'),
          ),
        ],
      ),
    );
  }

  void _submitOrder() {
    // Logique de soumission de la commande
  }
}

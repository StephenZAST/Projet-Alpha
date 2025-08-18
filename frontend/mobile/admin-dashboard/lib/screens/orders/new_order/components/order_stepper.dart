import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import 'steps/client_selection_step.dart';
import 'steps/service_selection_step.dart';
import 'steps/order_summary_step.dart';
import 'steps/order_address_step.dart';
import '../../../../widgets/shared/glass_button.dart';

class OrderStepper extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  final steps = [
    'Sélection du client',
    'Service',
    'Adresse',
    'Récapitulatif',
  ];

  Widget _buildStep(int index) {
    switch (index) {
      case 0:
        return ClientSelectionStep();
      case 1:
        return ServiceSelectionStep();
      case 2:
        return OrderAddressStep();
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
          child: Obx(() => _buildStep(controller.currentStep.value)),
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
          GlassButton(
            label: 'Retour',
            icon: Icons.arrow_back,
            variant: GlassButtonVariant.secondary,
            onPressed: () {
              if (controller.currentStep.value > 0) {
                controller.currentStep.value--;
              } else {
                Get.back();
              }
            },
          ),
          Obx(() => GlassButton(
                label: controller.currentStep.value < steps.length - 1
                    ? 'Suivant'
                    : 'Créer la commande',
                icon: controller.currentStep.value < steps.length - 1
                    ? Icons.arrow_forward
                    : Icons.check,
                variant: GlassButtonVariant.primary,
                onPressed: _canProceedToNextStep()
                    ? () {
                        if (controller.currentStep.value < steps.length - 1) {
                          controller.currentStep.value++;
                        } else {
                          _submitOrder();
                        }
                      }
                    : null,
              )),
        ],
      ),
    );
  }

  bool _canProceedToNextStep() {
    switch (controller.currentStep.value) {
      case 0:
        return controller.selectedClientId.value != null;
      case 1:
        // Pour valider l'étape Service, il faut un service ET au moins un article sélectionné
        return controller.selectedServiceId.value != null &&
            controller.selectedItems.isNotEmpty;
      case 2:
        // Pour valider l'étape Adresse, il faut une adresse sélectionnée
        return controller.selectedAddressId.value != null &&
            controller.selectedAddressId.value!.isNotEmpty;
      default:
        return true;
    }
  }

  void _submitOrder() {
    final addressId = controller.selectedAddressId.value;
    final serviceId = controller.selectedServiceId.value;
    final items = controller
        .getRecapOrderItems()
        .where((item) => (item['article']?.id ?? item['articleId']) != null)
        .map((item) => {
              'articleId': item['article']?.id ?? item['articleId'],
              'quantity': item['quantity'],
              'isPremium': item['isPremium'] ?? false,
            })
        .toList();

    // Debug log détaillé
    print('[OrderStepper] addressId: $addressId');
    print('[OrderStepper] serviceId: $serviceId');
    print('[OrderStepper] items: $items');
    final orderData = <String, dynamic>{
      'addressId': addressId,
      'serviceId': serviceId,
      'items': items,
      // Ajoute d'autres champs nécessaires ici (dates, code promo, etc.)
    };
    print('[OrderStepper] Payload envoyé au backend: $orderData');

    // Vérification stricte
    if (addressId == null ||
        addressId.isEmpty ||
        serviceId == null ||
        serviceId.isEmpty ||
        items.isEmpty) {
      Get.snackbar('Erreur',
          'Veuillez remplir tous les champs obligatoires (service, adresse, articles).');
      return;
    }

    controller.createOrder(orderData);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import 'steps/client_selection_step.dart';
import 'steps/service_selection_step.dart';
import 'steps/order_summary_step.dart';
import 'steps/order_address_step.dart';
import 'steps/order_extra_fields_step.dart';
import '../../../../widgets/shared/glass_button.dart';
import '../../../../services/article_service_couple_service.dart';

class OrderStepper extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  final steps = [
    'Sélection du client',
    'Service',
    'Adresse',
    'Informations complémentaires',
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
        return OrderExtraFieldsStep();
      case 4:
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
      child: Obx(() => Row(
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
              GlassButton(
                label: controller.currentStep.value < steps.length - 1
                    ? 'Suivant'
                    : 'Créer la commande',
                icon: controller.currentStep.value < steps.length - 1
                    ? Icons.arrow_forward
                    : Icons.check,
                variant: GlassButtonVariant.primary,
                onPressed: () async {
                  // Debug : print l'état du cache et du contexte à chaque étape
                  print('[OrderStepper] Step: ${controller.currentStep.value}');
                  print(
                      '[OrderStepper] Etat du cache selectedArticleDetails: ${controller.selectedArticleDetails}');
                  print(
                      '[OrderStepper] Etat du draft: ${controller.orderDraft.value.toPayload()}');
                  // Correction : forcer l'adresse par défaut si aucune n'est sélectionnée
                  if (controller.currentStep.value == 2) {
                    if (controller.selectedAddressId.value == null &&
                        controller.clientAddresses.isNotEmpty) {
                      final defaultAddress = controller.clientAddresses.first;
                      controller.selectAddress(defaultAddress.id);
                      controller.setSelectedAddress(defaultAddress.id);
                    }
                  }
                  // Synchronisation du cache à partir du draft juste avant le récap
                  if (controller.currentStep.value == 2) {
                    // On va passer à l'étape récapitulatif (step 3)
                    // Recharge dynamiquement les couples depuis l'API
                    final items = controller.orderDraft.value.items;
                    final serviceTypeId =
                        controller.orderDraft.value.serviceTypeId;
                    final serviceId = controller.orderDraft.value.serviceId;
                    List<Map<String, dynamic>> couples = [];
                    if (serviceTypeId != null && serviceId != null) {
                      try {
                        couples = await ArticleServiceCoupleService
                            .getCouplesForServiceType(
                          serviceTypeId: serviceTypeId,
                          serviceId: serviceId,
                        );
                        print(
                            '[OrderStepper] Couples rechargés depuis l\'API: ${couples.length} couples');
                      } catch (e) {
                        print(
                            '[OrderStepper] Erreur lors du rechargement des couples: $e');
                      }
                    }
                    final selectedService = controller.lastSelectedService;
                    final selectedServiceType =
                        controller.lastSelectedServiceType;
                    final isPremium = controller.lastIsPremium;
                    final weight = controller.lastWeight;
                    final showPremiumSwitch = controller.lastShowPremiumSwitch;
                    // Reconstruit la map des articles sélectionnés (articleId -> quantité)
                    final selectedArticles = <String, int>{};
                    for (final item in items) {
                      selectedArticles[item.articleId] = item.quantity;
                    }
                    controller.syncSelectedItemsFrom(
                      selectedArticles: selectedArticles,
                      couples: couples,
                      isPremium: isPremium,
                      selectedService: selectedService,
                      selectedServiceType: selectedServiceType,
                      weight: weight,
                      showPremiumSwitch: showPremiumSwitch,
                    );
                    print(
                        '[OrderStepper] Synchronisation du cache selectedArticleDetails à partir du draft avec couples enrichis avant le récap.');
                  }
                  if (controller.currentStep.value < steps.length - 1) {
                    controller.currentStep.value++;
                  } else {
                    _submitOrder();
                  }
                },
              ),
            ],
          )),
    );
  }

  bool _canProceedToNextStep() {
    switch (controller.currentStep.value) {
      case 0:
        return controller.orderDraft.value.clientId != null;
      case 1:
        // Pour valider l'étape Service, il faut un service ET au moins un article sélectionné
        return controller.orderDraft.value.serviceId != null &&
            controller.orderDraft.value.items.isNotEmpty;
      case 2:
        // Pour valider l'étape Adresse, il faut une adresse sélectionnée
        return controller.orderDraft.value.addressId != null &&
            (controller.orderDraft.value.addressId?.isNotEmpty ?? false);
      default:
        return true;
    }
  }

  void _submitOrder() {
    // Utilise le système centralisé OrderDraft pour construire le payload
    final orderData = controller.buildOrderPayload();

    // Debug log détaillé
    print('[OrderStepper] Payload envoyé au backend: $orderData');

    // Vérification stricte
    if (orderData['addressId'] == null ||
        (orderData['addressId'] as String).isEmpty ||
        orderData['serviceId'] == null ||
        (orderData['serviceId'] as String).isEmpty ||
        orderData['items'] == null ||
        (orderData['items'] as List).isEmpty) {
      Get.snackbar('Erreur',
          'Veuillez remplir tous les champs obligatoires (service, adresse, articles).');
      return;
    }

    controller.createOrder(orderData);
  }
}

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
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlassButton(
              label: 'Retour',
              icon: Icons.arrow_back,
              variant: GlassButtonVariant.secondary,
              onPressed: isLoading
                  ? null
                  : () {
                      if (controller.currentStep.value > 0) {
                        controller.currentStep.value--;
                      } else {
                        Get.back();
                      }
                    },
            ),
            controller.currentStep.value < steps.length - 1
                ? GlassButton(
                    label: 'Suivant',
                    icon: Icons.arrow_forward,
                    variant: GlassButtonVariant.primary,
                    onPressed: isLoading
                        ? null
                        : () async {
                            // ...étapes intermédiaires inchangées...
                            if (controller.currentStep.value == 2) {
                              if (controller.selectedAddressId.value == null &&
                                  controller.clientAddresses.isNotEmpty) {
                                final defaultAddress =
                                    controller.clientAddresses.first;
                                controller.selectAddress(defaultAddress.id);
                                controller
                                    .setSelectedAddress(defaultAddress.id);
                              }
                            }
                            if (controller.currentStep.value == 2) {
                              final items = controller.orderDraft.value.items;
                              final serviceTypeId =
                                  controller.orderDraft.value.serviceTypeId;
                              final serviceId =
                                  controller.orderDraft.value.serviceId;
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
                              final selectedService =
                                  controller.lastSelectedService;
                              final selectedServiceType =
                                  controller.lastSelectedServiceType;
                              final isPremium = controller.lastIsPremium;
                              final weight = controller.lastWeight;
                              final showPremiumSwitch =
                                  controller.lastShowPremiumSwitch;
                              final selectedArticles = <String, int>{};
                              for (final item in items) {
                                selectedArticles[item.articleId] =
                                    item.quantity;
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
                            controller.currentStep.value++;
                          },
                  )
                : GlassButton(
                    label: isLoading ? 'Création...' : 'Créer la commande',
                    icon: isLoading ? null : Icons.check,
                    variant: GlassButtonVariant.primary,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                            await _submitOrderWithLoader();
                          },
                  ),
          ],
        );
      }),
    );
  }

  Future<void> _submitOrderWithLoader() async {
    final orderData = controller.buildOrderPayload();
    print('[OrderStepper] Payload envoyé au backend: $orderData');
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
    try {
      await controller.createOrder(orderData);
      Get.back(); // Ferme le stepper après succès
      Future.delayed(Duration(milliseconds: 100), () {
        controller.fetchOrders(); // Recharge la liste des commandes
      });
    } catch (_) {}
  }
}

// Les méthodes _canProceedToNextStep et _submitOrder sont supprimées car non utilisées

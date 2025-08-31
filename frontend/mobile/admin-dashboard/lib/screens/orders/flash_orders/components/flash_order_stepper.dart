import 'package:admin/screens/orders/flash_orders/components/flash_steps/flash_client_step.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/flash_order_stepper_controller.dart';
import 'flash_steps/flash_service_step.dart';
import 'flash_steps/flash_address_step.dart';
import 'flash_steps/flash_extra_fields_step.dart';
import 'flash_steps/flash_summary_step.dart';
import '../../../../widgets/shared/glass_button.dart';

class FlashOrderStepper extends StatelessWidget {
  final FlashOrderStepperController controller =
      Get.find<FlashOrderStepperController>();

  List<Widget> get steps => [
        FlashClientStep(controller: controller),
        FlashServiceStep(controller: controller),
        FlashAddressStep(controller: controller),
        FlashExtraFieldsStep(controller: controller),
        FlashSummaryStep(controller: controller),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() => steps[controller.currentStep.value]),
        ),
        _buildStepperControls(context),
      ],
    );
  }

  Widget _buildStepperControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
                        controller.previousStep();
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
                        : () {
                            controller.nextStep();
                          },
                  )
                : GlassButton(
                    label:
                        isLoading ? 'Conversion...' : 'Valider la conversion',
                    icon: isLoading ? null : Icons.check,
                    variant: GlassButtonVariant.primary,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                            await controller.submitConversion();
                          },
                  ),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/order.dart';
import '../../../../constants.dart';
import '../../../../controllers/flash_order_stepper_controller.dart';
import 'flash_order_stepper.dart';
import 'copy_text_icon.dart';
import '../../../../widgets/shared/glass_button.dart';

class FlashOrderDetailDialog extends StatelessWidget {
  final Order order;
  const FlashOrderDetailDialog({Key? key, required this.order})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ...infos commande, articles, note...
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Convertir en commande normale',
                    icon: Icons.transform,
                    variant: GlassButtonVariant.primary,
                    onPressed: () {
                      final stepperController =
                          Get.put(FlashOrderStepperController());
                      stepperController.initDraftFromFlashOrder(order);
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: SizedBox(
                            width: 600,
                            child: FlashOrderStepper(),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  GlassButton(
                    label: 'Fermer',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('ID: #${order.id}', style: AppTextStyles.bodyMedium),
                  CopyTextIcon(value: order.id, tooltip: 'Copier l\'ID'),
                ],
              ),
              if (order.customerName != null &&
                  order.customerName!.isNotEmpty) ...[
                Row(
                  children: [
                    Text('Client: ${order.customerName}',
                        style: AppTextStyles.bodyMedium),
                    CopyTextIcon(
                        value: order.customerName ?? '',
                        tooltip: 'Copier le nom'),
                  ],
                ),
              ],
              if (order.customerPhone != null &&
                  order.customerPhone!.isNotEmpty) ...[
                Row(
                  children: [
                    Text('Téléphone: ${order.customerPhone}',
                        style: AppTextStyles.bodySmall),
                    CopyTextIcon(
                        value: order.customerPhone ?? '',
                        tooltip: 'Copier le téléphone'),
                  ],
                ),
              ],
              if (order.user != null && order.user!.email.isNotEmpty) ...[
                Row(
                  children: [
                    Text('Email: ${order.user!.email}',
                        style: AppTextStyles.bodySmall),
                    CopyTextIcon(
                        value: order.user!.email, tooltip: 'Copier l\'email'),
                  ],
                ),
              ],
              if (order.deliveryAddress != null) ...[
                Text('Adresse: ${order.deliveryAddress}',
                    style: AppTextStyles.bodySmall),
              ],
              Text('Statut: ${order.status}', style: AppTextStyles.bodySmall),
              Text('Montant total: ${order.formattedTotal}',
                  style: AppTextStyles.bodyMedium),
              SizedBox(height: AppSpacing.sm),
              if (order.items != null && order.items!.isNotEmpty) ...[
                Text('Articles:',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                ...order.items!.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                          '- ${item.article?.name ?? item.articleId} x${item.quantity}'),
                    )),
              ],
              if (order.note != null && order.note!.isNotEmpty) ...[
                SizedBox(height: AppSpacing.sm),
                Text('Note: ${order.note}',
                    style: AppTextStyles.bodySmall
                        .copyWith(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

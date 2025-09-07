import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../models/delivery.dart';

class DeliverersTable extends StatelessWidget {
  const DeliverersTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DeliveryController controller = Get.find<DeliveryController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.radiusMD,
          ),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final List<DeliveryUser> list = controller.filteredDeliverers;

      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.radiusMD,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Aucun livreur trouvé', style: AppTextStyles.bodyLarge),
              SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () => controller.loadDeliverers(),
                icon: Icon(Icons.refresh),
                label: Text('Rafraîchir'),
              )
            ],
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.radiusMD,
        ),
        child: Column(
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Liste des livreurs', style: AppTextStyles.h3),
                Row(children: [
                  IconButton(
                    tooltip: 'Rafraîchir',
                    onPressed: () => controller.loadDeliverers(),
                    icon: Icon(Icons.refresh),
                  ),
                ]),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Table / List
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final d = list[index];
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  leading: CircleAvatar(
                    backgroundColor:
                        d.isActive ? AppColors.success : AppColors.gray400,
                    child: Text(d.firstName.isNotEmpty ? d.firstName[0] : '?'),
                  ),
                  title: Text(d.fullName, style: AppTextStyles.bodyLarge),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.email, style: AppTextStyles.bodySmallSecondary),
                      if (d.phone != null)
                        Text(d.phone!, style: AppTextStyles.bodySmall),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(d.statusLabel),
                        backgroundColor: d.statusColor.withOpacity(0.12),
                        avatar:
                            Icon(Icons.person, size: 16, color: d.statusColor),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'select') {
                            await controller.selectDeliverer(d);
                            // open detail panel if needed
                          } else if (value == 'toggle') {
                            final newStatus = !d.isActive;
                            await controller.toggleDelivererStatus(
                                d.id, newStatus);
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Confirmer'),
                                content: Text(
                                    'Supprimer le livreur ${d.fullName} ?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text('Annuler')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: Text('Supprimer')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await controller.deleteDeliverer(d.id);
                            }
                          } else if (value == 'edit') {
                            // Navigate to edit screen or open modal (not implemented here)
                            Get.snackbar('Info',
                                'Ouvrir formulaire d\'édition (à implémenter)');
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'select', child: Text('Voir')),
                          PopupMenuItem(value: 'edit', child: Text('Éditer')),
                          PopupMenuItem(
                              value: 'toggle',
                              child: Text('Activer/Désactiver')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Supprimer')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

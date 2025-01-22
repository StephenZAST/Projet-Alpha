import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../controllers/service_controller.dart';
import '../../../models/service.dart';
import 'service_form_screen.dart';

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'fcfa',
      decimalDigits: 0,
    );

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (service.description != null &&
                        service.description!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        service.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: (String value) {
                  switch (value) {
                    case 'edit':
                      Get.dialog(ServiceFormScreen(service: service));
                      break;
                    case 'delete':
                      Get.dialog(
                        AlertDialog(
                          title: Text('Confirmation'),
                          content: Text(
                            'Voulez-vous vraiment supprimer le service "${service.name}" ?',
                          ),
                          actions: [
                            TextButton(
                              child: Text('Annuler'),
                              onPressed: () => Get.back(),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: Text('Supprimer'),
                              onPressed: () {
                                Get.back();
                                controller.deleteService(service.id);
                              },
                            ),
                          ],
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Supprimer',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Prix',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            currencyFormat.format(service.price),
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

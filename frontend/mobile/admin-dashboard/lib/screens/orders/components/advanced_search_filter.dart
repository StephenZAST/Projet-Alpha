import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import 'dart:ui';

class AdvancedSearchFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: defaultPadding),
      child: ClipRRect(
        borderRadius: AppRadius.radiusMD,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBg.withOpacity(0.8)
                  : AppColors.white.withOpacity(0.8),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recherche avancée',
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh_outlined),
                      onPressed: () {
                        controller.resetFilters();
                        controller.fetchOrders();
                      },
                      tooltip: 'Réinitialiser les filtres',
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),

                // Champ de recherche
                TextFormField(
                  onChanged: controller.searchOrders,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une commande...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusSM,
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Filtres par date
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => TextFormField(
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: controller.filterStartDate.value ??
                                    DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                controller.filterStartDate.value = date;
                                controller.fetchOrders();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Date début',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusSM,
                              ),
                            ),
                            controller: TextEditingController(
                              text: controller.filterStartDate.value
                                      ?.toString()
                                      .split(' ')[0] ??
                                  '',
                            ),
                          )),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Obx(() => TextFormField(
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: controller.filterEndDate.value ??
                                    DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                controller.filterEndDate.value = date;
                                controller.fetchOrders();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Date fin',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusSM,
                              ),
                            ),
                            controller: TextEditingController(
                              text: controller.filterEndDate.value
                                      ?.toString()
                                      .split(' ')[0] ??
                                  '',
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

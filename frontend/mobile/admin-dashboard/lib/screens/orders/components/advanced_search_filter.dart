import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';

class AdvancedSearchFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recherche avancée', style: AppTextStyles.h3),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: controller.resetAdvancedSearch,
                tooltip: 'Réinitialiser les filtres',
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          Row(
            children: [
              // Filtre par période
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Période', style: AppTextStyles.bodyBold),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _DateFilterChip(
                          label: "Aujourd'hui",
                          value: 'today',
                          onSelected: controller.setDateFilter,
                        ),
                        SizedBox(width: 8),
                        _DateFilterChip(
                          label: '7 derniers jours',
                          value: 'week',
                          onSelected: controller.setDateFilter,
                        ),
                        SizedBox(width: 8),
                        _DateFilterChip(
                          label: '30 derniers jours',
                          value: 'month',
                          onSelected: controller.setDateFilter,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filtre par méthode de paiement
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paiement', style: AppTextStyles.bodyBold),
                    SizedBox(height: 8),
                    Obx(() => DropdownButton<PaymentMethod>(
                          value: controller.selectedPaymentMethod.value,
                          hint: Text('Tous'),
                          onChanged: (value) {
                            controller.selectedPaymentMethod.value = value;
                            controller.applyAdvancedSearch();
                          },
                          items: PaymentMethod.values
                              .map((method) => DropdownMenuItem(
                                    value: method,
                                    child:
                                        Text(method.toString().split('.').last),
                                  ))
                              .toList(),
                        )),
                  ],
                ),
              ),

              // Filtre par montant
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Montant', style: AppTextStyles.bodyBold),
                    SizedBox(height: 8),
                    Obx(() => RangeSlider(
                          values: RangeValues(
                            controller.priceRange[0],
                            controller.priceRange[1],
                          ),
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          labels: RangeLabels(
                            '${controller.priceRange[0]} fcfa',
                            '${controller.priceRange[1]} fcfa',
                          ),
                          onChanged: (values) {
                            controller.priceRange.value = [
                              values.start,
                              values.end
                            ];
                          },
                          onChangeEnd: (_) => controller.applyAdvancedSearch(),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onSelected;

  const _DateFilterChip({
    required this.label,
    required this.value,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return Obx(() => FilterChip(
          label: Text(label),
          selected: controller.selectedDateFilter.value == value,
          onSelected: (_) => onSelected(value),
        ));
  }
}

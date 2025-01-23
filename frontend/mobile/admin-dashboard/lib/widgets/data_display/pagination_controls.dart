import 'package:flutter/material.dart';
import '../../constants.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;
  final Function() onNextPage;
  final Function() onPreviousPage;
  final Function(int) onItemsPerPageChanged;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onItemsPerPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Informations de pagination
          Expanded(
            child: Text(
              'Page $currentPage sur $totalPages (Total: $totalItems)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),

          // Contrôles de pagination
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sélecteur d'éléments par page
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: itemsPerPage,
                    items: [10, 25, 50, 100].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value par page',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        onItemsPerPageChanged(newValue);
                      }
                    },
                    style: theme.textTheme.bodyMedium,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),

              SizedBox(width: AppSpacing.md),

              // Boutons de navigation
              Row(
                children: [
                  // Bouton précédent
                  IconButton(
                    onPressed: currentPage > 1 ? onPreviousPage : null,
                    icon: Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      padding: AppSpacing.paddingSM,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusSM,
                        side: BorderSide(
                          color: currentPage > 1
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: AppSpacing.sm),

                  // Bouton suivant
                  IconButton(
                    onPressed: currentPage < totalPages ? onNextPage : null,
                    icon: Icon(Icons.chevron_right),
                    style: IconButton.styleFrom(
                      padding: AppSpacing.paddingSM,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusSM,
                        side: BorderSide(
                          color: currentPage < totalPages
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

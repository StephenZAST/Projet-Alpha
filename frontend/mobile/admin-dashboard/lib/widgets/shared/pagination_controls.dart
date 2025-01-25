import 'package:flutter/material.dart';
import '../../constants.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.gray400 : AppColors.textMuted;

    final startItem = ((currentPage - 1) * itemsPerPage) + 1;
    final endItem = currentPage * itemsPerPage > totalItems
        ? totalItems
        : currentPage * itemsPerPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Information sur les éléments affichés
        Text(
          'Affichage $startItem-$endItem sur $totalItems',
          style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
        ),

        Row(
          children: [
            // Sélecteur d'éléments par page
            DropdownButton<int>(
              value: itemsPerPage,
              items: [25, 50, 100].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    '$value par page',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onItemsPerPageChanged(newValue);
                }
              },
              style: AppTextStyles.bodyMedium,
              dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
            ),
            SizedBox(width: AppSpacing.lg),

            // Boutons de navigation
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: currentPage > 1 ? onPreviousPage : null,
                  color: currentPage > 1 ? textColor : mutedColor,
                  tooltip: 'Page précédente',
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.gray800 : AppColors.gray100,
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Text(
                    'Page $currentPage sur $totalPages',
                    style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages ? onNextPage : null,
                  color: currentPage < totalPages ? textColor : mutedColor,
                  tooltip: 'Page suivante',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

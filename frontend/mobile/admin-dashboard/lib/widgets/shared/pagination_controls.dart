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
    // Définir les options uniques pour le nombre d'éléments par page
    final itemsPerPageOptions = [10, 25, 50, 100];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dropdown pour items par page
        Row(
          children: [
            Text('Éléments par page: ', style: AppTextStyles.bodyMedium),
            SizedBox(width: 8),
            DropdownButton<int>(
              value: itemsPerPage,
              items: itemsPerPageOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onItemsPerPageChanged(newValue);
                }
              },
            ),
          ],
        ),

        // Information sur la pagination
        Text(
          'Page $currentPage sur $totalPages (Total: $totalItems)',
          style: AppTextStyles.bodyMedium,
        ),

        // Boutons de navigation
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: currentPage > 1 ? onPreviousPage : null,
              color: currentPage > 1 ? AppColors.primary : AppColors.gray400,
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: currentPage < totalPages ? onNextPage : null,
              color: currentPage < totalPages
                  ? AppColors.primary
                  : AppColors.gray400,
            ),
          ],
        ),
      ],
    );
  }
}

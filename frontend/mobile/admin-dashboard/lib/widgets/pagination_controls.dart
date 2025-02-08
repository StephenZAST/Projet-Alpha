import 'package:flutter/material.dart';
import '../constants.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int? itemCount;
  final int? totalItems;
  final int? itemsPerPage;
  final void Function(int?)? onItemsPerPageChanged;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    this.itemCount,
    this.totalItems,
    this.itemsPerPage,
    this.onItemsPerPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (itemsPerPage != null && onItemsPerPageChanged != null)
            _buildItemsPerPageSelector(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: currentPage > 1 ? onPrevious : null,
                  tooltip: 'Page précédente',
                ),
                SizedBox(width: AppSpacing.md),
                _buildPageInfo(),
                SizedBox(width: AppSpacing.md),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages ? onNext : null,
                  tooltip: 'Page suivante',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Page $currentPage sur $totalPages',
          style: AppTextStyles.bodyMedium,
        ),
        if (itemCount != null && totalItems != null)
          Text(
            'Affichage de $itemCount sur $totalItems éléments',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildItemsPerPageSelector() {
    return Row(
      children: [
        Text('Éléments par page:', style: AppTextStyles.bodyMedium),
        SizedBox(width: AppSpacing.sm),
        DropdownButton<int>(
          value: itemsPerPage,
          items: [10, 25, 50, 100].map((value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
          onChanged: onItemsPerPageChanged,
        ),
      ],
    );
  }
}

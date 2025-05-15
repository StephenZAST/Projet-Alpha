import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemCount;
  final int totalItems;
  final int itemsPerPage;
  final Function() onPrevious;
  final Function() onNext;
  final Function(int?) onItemsPerPageChanged;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.itemCount,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPrevious,
    required this.onNext,
    required this.onItemsPerPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Affichage du nombre d'éléments par page
          Row(
            children: [
              Text('Afficher'),
              SizedBox(width: 8),
              DropdownButton<int>(
                value: itemsPerPage,
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
                onChanged: onItemsPerPageChanged,
              ),
              SizedBox(width: 8),
              Text('éléments'),
            ],
          ),
          // Navigation entre les pages
          if (totalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: currentPage > 1 ? onPrevious : null,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Page $currentPage sur $totalPages'),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages ? onNext : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

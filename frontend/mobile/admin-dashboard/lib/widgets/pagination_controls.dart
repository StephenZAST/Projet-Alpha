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
  final ValueChanged<int?>? onPageChanged;

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
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int start = ((currentPage - 1) * itemsPerPage) + 1;
    int end = (start + itemCount - 1).clamp(1, totalItems);
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
          // Affichage de la plage d'éléments
          Text('$start–$end sur $totalItems'),
          // Navigation entre les pages
          if (totalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: currentPage > 1 ? onPrevious : null,
                ),
                if (totalPages > 5 && onPageChanged != null)
                  DropdownButton<int>(
                    value: currentPage,
                    items: List.generate(totalPages, (i) => i + 1)
                        .map((page) => DropdownMenuItem(
                              value: page,
                              child: Text('Page $page'),
                            ))
                        .toList(),
                    onChanged: onPageChanged,
                  )
                else
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

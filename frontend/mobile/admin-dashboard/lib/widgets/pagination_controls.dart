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
    // Guards pour éviter les incohérences
    final safeTotalItems = totalItems < 0 ? 0 : totalItems;
    final safeItemsPerPage = itemsPerPage < 1 ? 10 : itemsPerPage;
    final safeTotalPages = totalPages < 1 ? 1 : totalPages;
    final safeCurrentPage = currentPage < 1
        ? 1
        : (currentPage > safeTotalPages ? safeTotalPages : currentPage);
    final safeItemCount = itemCount < 0 ? 0 : itemCount;

    // Calcul de la plage d'éléments affichés
    int start = safeTotalItems == 0
        ? 0
        : ((safeCurrentPage - 1) * safeItemsPerPage) + 1;
    int end = safeTotalItems == 0
        ? 0
        : (start + safeItemCount - 1).clamp(start, safeTotalItems);
    if (start > end) start = end;

    // Debug print
    print(
        '[PaginationControls] currentPage: $safeCurrentPage, totalPages: $safeTotalPages, itemsPerPage: $safeItemsPerPage, itemCount: $safeItemCount, totalItems: $safeTotalItems, start: $start, end: $end');

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
                value: safeItemsPerPage,
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
          // Affichage de la plage d'éléments (ne rien afficher si aucun résultat)
          Text(safeTotalItems == 0 ? '' : '$start–$end sur $safeTotalItems'),
          // Navigation entre les pages
          if (safeTotalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: safeCurrentPage > 1 ? onPrevious : null,
                ),
                DropdownButton<int>(
                  value: safeCurrentPage,
                  items: List.generate(safeTotalPages, (i) => i + 1)
                      .map((page) => DropdownMenuItem(
                            value: page,
                            child: Text('Page $page'),
                          ))
                      .toList(),
                  onChanged: onPageChanged ?? (v) {}, // désactivé si null
                  disabledHint:
                      Text('Page $safeCurrentPage sur $safeTotalPages'),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: safeCurrentPage < safeTotalPages ? onNext : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

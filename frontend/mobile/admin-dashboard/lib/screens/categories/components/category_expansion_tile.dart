import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../constants.dart';

class CategoryExpansionTile extends StatelessWidget {
  final Category category;
  final Function(Category) onEdit;
  final Function(Category) onDelete;
  const CategoryExpansionTile({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            // Nom à gauche
            Expanded(
              flex: 3,
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Statut au centre
            if (!category.isActive)
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Inactive',
                        style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
                ),
              ),
            // Nombre d'articles à droite
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${category.articlesCount} article${category.articlesCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Détails',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 6),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Nom : ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: category.name),
                ])),
                if (category.description != null &&
                    category.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'Description : ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: category.description!),
                    ])),
                  ),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Articles : ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${category.articlesCount}'),
                ])),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Créée le : ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${category.createdAt.toLocal()}'),
                ])),
                if (category.updatedAt != null)
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'Modifiée le : ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '${category.updatedAt!.toLocal()}'),
                  ])),
                SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit(category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onDelete(category),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

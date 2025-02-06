import 'package:admin/screens/articles/components/article_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../models/article.dart';
import '../../../controllers/article_controller.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    article.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Menu d'actions
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Get.dialog(
                          ArticleFormDialog(
                            article: article,
                          ),
                          barrierDismissible: false,
                        );
                        break;
                      case 'delete':
                        _showDeleteDialog(context, controller);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Supprimer',
                              style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (article.description != null) ...[
              SizedBox(height: 8),
              Text(
                article.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PriceDisplay(
                  label: 'Prix de base',
                  price: article.basePrice,
                  currencyFormat: currencyFormat,
                ),
                _PriceDisplay(
                  label: 'Prix premium',
                  price: article.premiumPrice ?? 0.0,
                  currencyFormat: currencyFormat,
                  isPremium: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ArticleController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cet article ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              controller.deleteArticle(article.id);
              Get.back();
            },
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final String label;
  final double price;
  final NumberFormat currencyFormat;
  final bool isPremium;

  const _PriceDisplay({
    required this.label,
    required this.price,
    required this.currencyFormat,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isPremium ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          currencyFormat.format(price),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isPremium ? Theme.of(context).primaryColor : null,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

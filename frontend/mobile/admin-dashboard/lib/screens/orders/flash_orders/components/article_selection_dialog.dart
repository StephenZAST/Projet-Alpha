import 'package:admin/models/flash_order_update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import '../../../../models/article.dart';

class ArticleSelectionDialog extends StatefulWidget {
  @override
  _ArticleSelectionDialogState createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends State<ArticleSelectionDialog> {
  final controller = Get.find<OrdersController>();
  Article? selectedArticle;
  int quantity = 1;
  bool isPremium = false;
  double? unitPrice;

  double getArticlePrice(Article article, bool isPremium) {
    return isPremium
        ? (article.premiumPrice ?? article.basePrice)
        : article.basePrice;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajouter un article', style: AppTextStyles.h3),
            SizedBox(height: AppSpacing.lg),

            // Sélection de l'article
            DropdownButtonFormField<Article>(
              value: selectedArticle,
              decoration: InputDecoration(
                labelText: 'Article',
                border: OutlineInputBorder(),
              ),
              items: controller.articles.map((article) {
                return DropdownMenuItem(
                  value: article,
                  child: Text(article.name),
                );
              }).toList(),
              onChanged: (article) {
                setState(() {
                  selectedArticle = article;
                  unitPrice =
                      isPremium ? article?.premiumPrice : article?.basePrice;
                });
              },
            ),
            SizedBox(height: AppSpacing.md),

            // Prix premium et quantité
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Service Premium'),
                    value: isPremium,
                    onChanged: (value) {
                      setState(() {
                        isPremium = value ?? false;
                        if (selectedArticle != null) {
                          unitPrice = isPremium
                              ? selectedArticle!.premiumPrice
                              : selectedArticle!.basePrice;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Container(
                  width: 120,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Total
            if (selectedArticle != null && unitPrice != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                'Total: ${(unitPrice! * quantity).toStringAsFixed(2)} FCFA',
                style: AppTextStyles.h4,
              ),
            ],

            SizedBox(height: AppSpacing.xl),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Annuler'),
                ),
                SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed: selectedArticle == null
                      ? null
                      : () {
                          final price =
                              getArticlePrice(selectedArticle!, isPremium);
                          controller.selectedArticles.add(FlashOrderItem(
                            articleId: selectedArticle!.id,
                            quantity: quantity,
                            unitPrice: price,
                            isPremium: isPremium,
                          ));
                          Get.back();
                        },
                  child: Text('Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

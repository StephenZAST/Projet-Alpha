import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import '../../../../models/article.dart';
import '../../../../models/flash_order_update.dart';

class ArticleSelectionDialog extends StatefulWidget {
  @override
  _ArticleSelectionDialogState createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends State<ArticleSelectionDialog> {
  final controller = Get.find<OrdersController>();
  late Article? selectedArticle;
  int quantity = 1;
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    selectedArticle = null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un article'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sélection de l'article
          DropdownButtonFormField<Article>(
            value: selectedArticle,
            hint: Text('Sélectionner un article'),
            items: controller.articles.map((article) {
              return DropdownMenuItem(
                value: article,
                child: Text(article.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedArticle = value;
              });
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Quantité
          Row(
            children: [
              Text('Quantité:'),
              Spacer(),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed:
                    quantity > 1 ? () => setState(() => quantity--) : null,
              ),
              Text(quantity.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => setState(() => quantity++),
              ),
            ],
          ),

          // Option Premium
          CheckboxListTile(
            title: Text('Service Premium'),
            value: isPremium,
            onChanged: (value) {
              setState(() {
                isPremium = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: selectedArticle == null
              ? null
              : () {
                  controller.selectedArticles.add(FlashOrderItem(
                    articleId: selectedArticle!.id,
                    quantity: quantity,
                    unitPrice: isPremium
                        ? selectedArticle!.premiumPrice
                        : selectedArticle!.basePrice,
                    isPremium: isPremium,
                  ));
                  Get.back();
                },
          child: Text('Ajouter'),
        ),
      ],
    );
  }
}

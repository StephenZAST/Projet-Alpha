import 'package:admin/models/article.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import '../../../../models/flash_order_update.dart';

class ArticleEditDialog extends StatefulWidget {
  final int itemIndex;

  const ArticleEditDialog({
    Key? key,
    required this.itemIndex,
  }) : super(key: key);

  @override
  _ArticleEditDialogState createState() => _ArticleEditDialogState();
}

class _ArticleEditDialogState extends State<ArticleEditDialog> {
  final controller = Get.find<OrdersController>();
  late FlashOrderItem item;
  late int quantity;
  late bool isPremium;

  @override
  void initState() {
    super.initState();
    item = controller.selectedArticles[widget.itemIndex];
    quantity = item.quantity;
    isPremium = item.isPremium;
  }

  double getArticlePrice(Article article, bool isPremium) {
    // Utiliser le prix de base comme fallback si le prix premium n'est pas disponible
    return isPremium
        ? (article.premiumPrice ?? article.basePrice)
        : article.basePrice;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier l\'article'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          onPressed: () {
            final article = controller.articles.firstWhere(
              (a) => a.id == item.articleId,
            );

            // Utiliser la méthode getArticlePrice pour gérer le cas nullable
            final price = getArticlePrice(article, isPremium);

            controller.selectedArticles[widget.itemIndex] = FlashOrderItem(
              articleId: item.articleId,
              quantity: quantity,
              unitPrice:
                  price, // Maintenant on est sûr d'avoir une valeur non-null
              isPremium: isPremium,
            );
            Get.back();
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }
}

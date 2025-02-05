import 'package:admin/screens/orders/flash_orders/components/article_edit_dialog.dart';
import 'package:admin/screens/orders/flash_orders/components/article_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';

class ArticleSelection extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Articles', style: AppTextStyles.h3),
            SizedBox(height: AppSpacing.md),

            // Liste des articles sélectionnés
            Obx(() => ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.selectedArticles.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final item = controller.selectedArticles[index];
                    return ListTile(
                      title: Text(
                        controller.articles
                            .firstWhere((a) => a.id == item.articleId)
                            .name,
                      ),
                      subtitle:
                          Text('${item.quantity} x ${item.unitPrice} FCFA'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => controller.removeItem(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditDialog(context, index),
                          ),
                        ],
                      ),
                    );
                  },
                )),

            // Bouton pour ajouter un article
            ElevatedButton.icon(
              onPressed: () => _showAddArticleDialog(context),
              icon: Icon(Icons.add),
              label: Text('Ajouter un article'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ArticleSelectionDialog(),
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => ArticleEditDialog(itemIndex: index),
    );
  }
}

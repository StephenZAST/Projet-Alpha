import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';

class ArticlesSelectionStep extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélectionner les articles', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.articles.length,
                  itemBuilder: (context, index) {
                    final article = controller.articles[index];
                    return ListTile(
                      title: Text(article.name),
                      subtitle: Text('${article.basePrice} FCFA'),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () => controller.addItem(article.id),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}

import 'package:admin/models/flash_order_update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';
import '../../../../models/article.dart';
import '../../../../services/article_price_service.dart';

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
  Map<String, dynamic>? priceData;
  bool isLoadingPrice = false;

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
              onChanged: (article) async {
                setState(() {
                  selectedArticle = article;
                  isLoadingPrice = true;
                  priceData = null;
                  unitPrice = null;
                });
                if (article != null &&
                    controller.selectedService.value != null) {
                  final serviceTypeId =
                      controller.selectedService.value!.serviceTypeId;
                  if (serviceTypeId != null) {
                    final data =
                        await ArticlePriceService.getArticleServicePrice(
                      articleId: article.id,
                      serviceTypeId: serviceTypeId,
                    );
                    setState(() {
                      priceData = data;
                      isLoadingPrice = false;
                      unitPrice = _getUnitPrice(data);
                    });
                  } else {
                    setState(() {
                      isLoadingPrice = false;
                    });
                  }
                } else {
                  setState(() {
                    isLoadingPrice = false;
                  });
                }
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
                    onChanged: (value) async {
                      setState(() {
                        isPremium = value ?? false;
                        isLoadingPrice = true;
                      });
                      if (selectedArticle != null &&
                          controller.selectedService.value != null) {
                        final serviceTypeId =
                            controller.selectedService.value!.serviceTypeId;
                        if (serviceTypeId != null) {
                          final data =
                              await ArticlePriceService.getArticleServicePrice(
                            articleId: selectedArticle!.id,
                            serviceTypeId: serviceTypeId,
                          );
                          setState(() {
                            priceData = data;
                            isLoadingPrice = false;
                            unitPrice = _getUnitPrice(data);
                          });
                        } else {
                          setState(() {
                            isLoadingPrice = false;
                          });
                        }
                      } else {
                        setState(() {
                          isLoadingPrice = false;
                        });
                      }
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
            if (isLoadingPrice)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            else if (selectedArticle != null && unitPrice != null) ...[
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
                  onPressed: selectedArticle == null ? null : addArticle,
                  child: Text('Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double? _getUnitPrice(Map<String, dynamic>? data) {
    if (data == null) return null;
    if (isPremium && data['premium_price'] != null) {
      return (data['premium_price'] as num).toDouble();
    } else if (data['base_price'] != null) {
      return (data['base_price'] as num).toDouble();
    }
    return null;
  }

  void addArticle() {
    if (selectedArticle == null || unitPrice == null) return;

    controller.selectedArticles.add(FlashOrderItem(
      articleId: selectedArticle!.id,
      quantity: quantity,
      unitPrice: unitPrice!,
      isPremium: isPremium,
    ));
    Get.back();
  }
}

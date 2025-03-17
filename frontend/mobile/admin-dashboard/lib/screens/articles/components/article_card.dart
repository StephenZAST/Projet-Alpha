import 'package:admin/screens/articles/components/article_form_dialog.dart';
import 'package:admin/widgets/shared/action_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:admin/theme/glass_style.dart';
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
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      child: Container(
        decoration: GlassStyle.containerDecoration(
          context: context,
          opacity: isDark ? 0.2 : 0.1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.article_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          article.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (article.description != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      article.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray600,
                            fontSize: 13,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceDisplay(
                        label: 'Base',
                        price: article.basePrice,
                        currencyFormat: currencyFormat,
                      ),
                      _PriceDisplay(
                        label: 'Premium',
                        price: article.premiumPrice ?? 0.0,
                        currencyFormat: currencyFormat,
                        isPremium: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.gray700 : AppColors.gray200),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ActionButton(
                      icon: Icons.edit_rounded,
                      label: 'Modifier',
                      color: AppColors.primary,
                      onTap: () => Get.dialog(
                        ArticleFormDialog(article: article),
                        barrierDismissible: false,
                      ),
                      variant: ActionButtonVariant.ghost,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: ActionButton(
                      icon: Icons.delete_rounded,
                      label: 'Supprimer',
                      color: AppColors.error,
                      onTap: () => _showDeleteDialog(context, controller),
                      variant: ActionButtonVariant.outlined,
                    ),
                  ),
                ],
              ),
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

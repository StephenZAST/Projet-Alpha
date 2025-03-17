import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../models/article.dart';
import '../../../widgets/shared/action_button.dart';

class ArticleListItem extends StatelessWidget {
  final Article article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ArticleListItem({
    Key? key,
    required this.article,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(
          Icons.article_outlined,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        article.name,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.description != null)
            Text(
              article.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Base: ${currencyFormat.format(article.basePrice)}',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(width: 16),
              Text(
                'Premium: ${currencyFormat.format(article.premiumPrice ?? 0)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionButton(
            icon: Icons.edit_rounded,
            label: '',
            color: AppColors.primary,
            onTap: onEdit,
            variant: ActionButtonVariant.ghost,
            isCompact: true,
          ),
          SizedBox(width: AppSpacing.xs),
          ActionButton(
            icon: Icons.delete_rounded,
            label: '',
            color: AppColors.error,
            onTap: onDelete,
            variant: ActionButtonVariant.ghost,
            isCompact: true,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/article.dart';

/// 📦 Card Article - Alpha Client App
///
/// Affiche un article sans prix (le prix dépend du service choisi)
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final bool showCategory;

  const ArticleCard({
    Key? key,
    required this.article,
    this.onTap,
    this.showCategory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColorForCategory(article.categoryName ?? '');
    
    return GlassContainer(
      onTap: onTap,
      isInteractive: onTap != null,
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adapter la taille selon la largeur disponible
          final isSmall = constraints.maxWidth < 100;
          final iconSize = isSmall ? 24.0 : 28.0;
          final iconHeight = isSmall ? 45.0 : 55.0;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icône
              Container(
                width: double.infinity,
                height: iconHeight,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForArticle(article.name),
                  color: color,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 6),
              
              // Nom - Flexible avec hauteur minimale
              Flexible(
                child: Text(
                  article.name,
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Catégorie - Seulement si assez d'espace
              if (showCategory && article.categoryName != null && !isSmall) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    article.categoryName!,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
              const SizedBox(height: 6),
              
              // Badge "Voir tarifs" - Compact
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 4 : 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.price_check,
                      size: isSmall ? 10 : 11,
                      color: AppColors.primary,
                    ),
                    if (!isSmall) ...[
                      const SizedBox(width: 3),
                      Text(
                        'Prix',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getColorForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('chemise') || name.contains('shirt')) {
      return AppColors.primary;
    } else if (name.contains('pantalon') || name.contains('pant')) {
      return AppColors.info;
    } else if (name.contains('robe') || name.contains('dress')) {
      return AppColors.pink;
    } else if (name.contains('costume') || name.contains('suit')) {
      return AppColors.secondary;
    } else if (name.contains('veste') || name.contains('jacket')) {
      return AppColors.warning;
    }
    return AppColors.accent;
  }

  IconData _getIconForArticle(String articleName) {
    final name = articleName.toLowerCase();
    if (name.contains('chemise') || name.contains('shirt')) {
      return Icons.checkroom;
    } else if (name.contains('pantalon') || name.contains('pant')) {
      return Icons.checkroom_outlined;
    } else if (name.contains('robe') || name.contains('dress')) {
      return Icons.woman;
    } else if (name.contains('costume') || name.contains('suit')) {
      return Icons.work_outline;
    } else if (name.contains('veste') || name.contains('jacket') || name.contains('manteau')) {
      return Icons.dry_cleaning;
    } else if (name.contains('cravate') || name.contains('tie')) {
      return Icons.style;
    }
    return Icons.checkroom;
  }
}

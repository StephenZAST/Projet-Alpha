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
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adapter la taille selon la largeur disponible
          final isSmall = constraints.maxWidth < 100;
          final iconSize = isSmall ? 28.0 : 36.0;
          final iconContainerHeight = isSmall ? 60.0 : 75.0;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icône avec gradient background
              Container(
                height: iconContainerHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // Icône principale
                    Center(
                      child: Icon(
                        _getIconForArticle(article.name),
                        color: color,
                        size: iconSize,
                      ),
                    ),
                    // Badge catégorie en haut à droite (si assez d'espace)
                    if (showCategory && article.categoryName != null && !isSmall)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            article.categoryName!.length > 8
                                ? '${article.categoryName!.substring(0, 8)}.'
                                : article.categoryName!,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Contenu avec padding
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmall ? 8.0 : 10.0,
                  isSmall ? 8.0 : 10.0,
                  isSmall ? 8.0 : 10.0,
                  isSmall ? 10.0 : 12.0, // Plus d'espace en bas
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nom de l'article - Conteneur avec hauteur minimale
                    Container(
                      constraints: BoxConstraints(
                        minHeight: isSmall ? 28 : 32, // Hauteur minimale pour 2 lignes
                      ),
                      child: Center(
                        child: Text(
                          article.name,
                          style: TextStyle(
                            fontSize: isSmall ? 10.5 : 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isSmall ? 8 : 10),
                    
                    // Badge "Voir tarifs" - Design amélioré
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 8 : 10,
                        vertical: isSmall ? 5 : 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: isSmall ? 11 : 12,
                            color: AppColors.primary,
                          ),
                          if (!isSmall) ...[
                            const SizedBox(width: 4),
                            Text(
                              'Tarifs',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

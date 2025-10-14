import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/services/pricing_service.dart';

/// 💰 Card Couple Article-Service-Price - Alpha Client App
///
/// Affiche un couple article-service avec ses prix (base et premium)
/// Design optimisé pour petits écrans, inspiré de article_card.dart
class ArticleServiceCoupleCard extends StatelessWidget {
  final ArticleServicePrice couple;
  final int quantity;
  final bool isPremium;
  final Function(int quantity) onQuantityChanged;
  final bool showCategory;

  const ArticleServiceCoupleCard({
    Key? key,
    required this.couple,
    required this.quantity,
    required this.isPremium,
    required this.onQuantityChanged,
    this.showCategory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColorForCategory(couple.articleName ?? '');
    final isSelected = quantity > 0;
    final currentPrice = isPremium ? (couple.premiumPrice ?? couple.basePrice) : couple.basePrice;
    
    return GlassContainer(
      onTap: isSelected ? null : () {
        HapticFeedback.lightImpact();
        onQuantityChanged(1);
      },
      isInteractive: !isSelected,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 100;
          final iconSize = isSmall ? 28.0 : 36.0;
          final iconContainerHeight = isSmall ? 60.0 : 75.0;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête avec icône et badge quantité
              Container(
                height: iconContainerHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(isSelected ? 0.25 : 0.15),
                      color.withOpacity(isSelected ? 0.15 : 0.05),
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
                        _getIconForArticle(couple.articleName ?? ''),
                        color: color,
                        size: iconSize,
                      ),
                    ),
                    
                    // Badge service (si assez d'espace)
                    if (showCategory && couple.serviceName != null && !isSmall)
                      Positioned(
                        top: 6,
                        left: 6,
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
                            _truncateServiceName(couple.serviceName!),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    
                    // Badge quantité (si sélectionné)
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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
                  isSmall ? 10.0 : 12.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nom de l'article
                    Container(
                      constraints: BoxConstraints(
                        minHeight: isSmall ? 28 : 32,
                      ),
                      child: Center(
                        child: Text(
                          couple.articleName ?? 'Article',
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
                    
                    SizedBox(height: isSmall ? 6 : 8),
                    
                    // Prix avec badge premium si applicable
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${currentPrice.toInt()} FCFA',
                          style: TextStyle(
                            fontSize: isSmall ? 11 : 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (isPremium && couple.premiumPrice != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: isSmall ? 12 : 14,
                          ),
                        ],
                      ],
                    ),
                    
                    SizedBox(height: isSmall ? 8 : 10),
                    
                    // Contrôles de quantité ou bouton ajouter
                    if (isSelected)
                      _buildQuantityControls(context, isSmall)
                    else
                      _buildAddButton(context, isSmall),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ➕ Bouton d'ajout
  Widget _buildAddButton(BuildContext context, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 5 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add,
            size: isSmall ? 14 : 16,
            color: Colors.white,
          ),
          if (!isSmall) ...[
            const SizedBox(width: 4),
            Text(
              'Ajouter',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🔢 Contrôles de quantité
  Widget _buildQuantityControls(BuildContext context, bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton moins/supprimer
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (quantity > 1) {
              onQuantityChanged(quantity - 1);
            } else {
              onQuantityChanged(0);
            }
          },
          child: Container(
            width: isSmall ? 28 : 32,
            height: isSmall ? 28 : 32,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              quantity > 1 ? Icons.remove : Icons.delete_outline,
              color: AppColors.error,
              size: isSmall ? 14 : 16,
            ),
          ),
        ),
        
        // Quantité
        Container(
          constraints: BoxConstraints(minWidth: isSmall ? 32 : 40),
          child: Center(
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ),
        
        // Bouton plus
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onQuantityChanged(quantity + 1);
          },
          child: Container(
            width: isSmall ? 28 : 32,
            height: isSmall ? 28 : 32,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.add,
              color: AppColors.success,
              size: isSmall ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForCategory(String articleName) {
    final name = articleName.toLowerCase();
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

  /// Tronque le nom du service pour l'affichage dans le badge
  String _truncateServiceName(String serviceName) {
    // Supprimer les mots communs pour gagner de l'espace
    String shortened = serviceName
        .replaceAll('Nettoyage', 'Nett.')
        .replaceAll('nettoyage', 'Nett.')
        .replaceAll('Repassage', 'Repass.')
        .replaceAll('repassage', 'Repass.')
        .replaceAll('Lavage', 'Lav.')
        .replaceAll('lavage', 'Lav.')
        .replaceAll('à sec', 'sec')
        .replaceAll('simple', '')
        .trim();
    
    // Si toujours trop long, tronquer à 12 caractères
    if (shortened.length > 12) {
      return '${shortened.substring(0, 12)}..';
    }
    
    return shortened;
  }
}

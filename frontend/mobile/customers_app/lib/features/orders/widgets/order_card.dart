import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../core/models/order.dart';

/// 📦 Card de Commande - Alpha Client App
///
/// Affiche un résumé d'une commande dans la liste avec design moderne
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    Key? key,
    required this.order,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: order.statusColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Barre de couleur latérale avec gradient
              Container(
                width: 6,
                constraints: const BoxConstraints(minHeight: 150),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      order.statusColor,
                      order.statusColor.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              // Contenu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 12),
                      _buildBody(context),
                      const SizedBox(height: 12),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 Header avec ID et statut
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // ID de la commande
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${order.shortOrderId}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(order.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Badge de statut moderne
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            order.statusText,
            style: AppTextStyles.labelSmall.copyWith(
              color: order.statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  /// 📦 Body avec articles
  Widget _buildBody(BuildContext context) {
    // 🔍 DEBUG: Logs pour vérifier les données
    print('[OrderCard] 📦 Order ID: ${order.id}');
    print('[OrderCard] 📊 Items count: ${order.items.length}');
    print('[OrderCard] 📋 Items: ${order.items.map((i) => i.articleName).join(", ")}');
    
    final displayItems = order.items.take(2).toList();
    final remainingCount = order.items.length - displayItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre d'articles
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Liste des articles (max 2)
        ...displayItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.articleName}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),

        // Indicateur d'articles supplémentaires
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+ $remainingCount autre${remainingCount > 1 ? 's' : ''}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary(context),
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  /// 📊 Footer avec total et paiement
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Indicateur de paiement
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: order.isPaid
                ? AppColors.success.withOpacity(0.12)
                : AppColors.warning.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                order.isPaid ? Icons.check_circle : Icons.schedule,
                size: 14,
                color: order.isPaid ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                order.isPaid ? 'Payé' : 'En attente',
                style: AppTextStyles.labelSmall.copyWith(
                  color: order.isPaid ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Total avec icône - 🎯 Affiche displayPrice (prix ajusté) ou totalAmount (prix original)
        Row(
          children: [
            Text(
              '${(order.displayPrice ?? order.totalAmount).toInt().toFormattedString()}',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'FCFA',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📅 Formater la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hier ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}

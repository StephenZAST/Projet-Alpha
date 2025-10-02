import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../components/glass_components.dart';
import '../../../../shared/providers/order_draft_provider.dart';

/// ✅ Étape de Résumé Final - Alpha Client App
///
/// Cinquième et dernière étape du workflow : récapitulatif complet et confirmation.
/// Interface optimisée pour mobile avec validation finale.
class OrderSummaryStep extends StatefulWidget {
  const OrderSummaryStep({Key? key}) : super(key: key);

  @override
  State<OrderSummaryStep> createState() => _OrderSummaryStepState();
}

class _OrderSummaryStepState extends State<OrderSummaryStep> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.fadeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.bounceIn,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDraftProvider>(
      builder: (context, provider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context),
                const SizedBox(height: 24),
                
                // Résumé de la commande
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildOrderSummary(context, provider),
                ),
                const SizedBox(height: 24),
                
                // Détails de livraison
                _buildDeliveryDetails(context, provider),
                const SizedBox(height: 24),
                
                // Articles commandés
                _buildOrderItems(context, provider),
                const SizedBox(height: 24),
                
                // Total et confirmation
                _buildTotalSection(context, provider),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📋 En-tête de l'étape
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Récapitulatif',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Vérifiez les détails avant de confirmer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📊 Résumé de la commande
  Widget _buildOrderSummary(BuildContext context, OrderDraftProvider provider) {
    final draft = provider.orderDraft;
    
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande Alpha',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Service ${provider.selectedService?.name ?? 'Premium'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${draft.totalItems} article(s)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Divider(color: AppColors.border(context)),
          const SizedBox(height: 20),
          
          // Informations clés
          _buildSummaryRow(
            context,
            'Type de Service',
            provider.selectedServiceType?.name ?? 'Standard',
            Icons.design_services,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            'Service',
            provider.selectedService?.name ?? 'Non spécifié',
            Icons.cleaning_services,
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            'Mode Tarification',
            provider.isPremium ? 'Premium' : 'Standard',
            provider.isPremium ? Icons.star : Icons.star_outline,
            provider.isPremium ? AppColors.warning : AppColors.success,
          ),
        ],
      ),
    );
  }

  /// 🚚 Détails de livraison
  Widget _buildDeliveryDetails(BuildContext context, OrderDraftProvider provider) {
    final draft = provider.orderDraft;
    final address = provider.selectedAddress;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.info,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Détails de Livraison',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Adresse
          _buildDetailRow(
            context,
            'Adresse',
            address != null 
                ? '${address.street}, ${address.city}'
                : 'Non spécifiée',
            Icons.location_on,
          ),
          
          // Dates
          if (draft.collectionDate != null)
            _buildDetailRow(
              context,
              'Collecte',
              _formatDate(draft.collectionDate!),
              Icons.schedule,
            ),
          
          if (draft.deliveryDate != null)
            _buildDetailRow(
              context,
              'Livraison',
              _formatDate(draft.deliveryDate!),
              Icons.event,
            ),
          
          // Méthode de paiement
          _buildDetailRow(
            context,
            'Paiement',
            _getPaymentMethodName(draft.paymentMethod ?? 'CASH'),
            Icons.payment,
          ),
          
          // Notes
          if (draft.note != null && draft.note!.isNotEmpty)
            _buildDetailRow(
              context,
              'Notes',
              draft.note!,
              Icons.note,
              maxLines: 3,
            ),
        ],
      ),
    );
  }

  /// 📦 Articles commandés
  Widget _buildOrderItems(BuildContext context, OrderDraftProvider provider) {
    final items = provider.orderDraft.items;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Articles Commandés',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...items.map((item) => _buildOrderItemRow(context, item)),
        ],
      ),
    );
  }

  /// 📦 Ligne d'article
  Widget _buildOrderItemRow(BuildContext context, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.checkroom,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.articleName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.isPremium) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  'Quantité: ${item.quantity}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.unitPrice.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                '${item.estimatedPrice.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💰 Section total
  Widget _buildTotalSection(BuildContext context, OrderDraftProvider provider) {
    final draft = provider.orderDraft;
    
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Total de la Commande',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Sous-total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sous-total',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                '${draft.estimatedTotal.toStringAsFixed(2)} FCFA',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          Divider(color: AppColors.border(context)),
          const SizedBox(height: 8),
          
          // Total final
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${draft.estimatedTotal.toStringAsFixed(2)} FCFA',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Note importante
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Le prix final peut varier selon l\'état réel des articles.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Ligne de résumé
  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 📋 Ligne de détail
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary(context),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 📅 Formater une date
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// 💳 Nom de la méthode de paiement
  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'CASH':
        return 'Espèces';
      case 'ORANGE_MONEY':
        return 'Orange Money';
      default:
        return method;
    }
  }
}
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/article.dart';
import '../../../core/services/pricing_service.dart';

/// 💰 Dialog Tarification Article - Alpha Client App
///
/// Affiche tous les prix disponibles pour un article selon les couples
/// (article_id, service_type_id, service_id) avec base_price et premium_price
class ArticlePricingDialog extends StatefulWidget {
  final Article article;

  const ArticlePricingDialog({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<ArticlePricingDialog> createState() => _ArticlePricingDialogState();
}

class _ArticlePricingDialogState extends State<ArticlePricingDialog> {
  final PricingService _pricingService = PricingService();
  bool _isLoading = true;
  String? _error;
  List<ArticleServicePrice> _prices = [];

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prices = await _pricingService.getArticlePrices(widget.article.id);

      setState(() {
        _prices = prices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.price_check,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.article.name,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.article.categoryName != null)
                          Text(
                            widget.article.categoryName!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Les prix varient selon le service choisi. Des réductions (jusqu\'à -70% cumulables) peuvent s\'appliquer — consultez les offres.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tableau des prix
              Text(
                'Tarification disponible',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Flexible(
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _prices.isEmpty
                            ? _buildEmptyState(context)
                            : SingleChildScrollView(
                                child: _buildPricingTable(context),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingTable(BuildContext context) {
    return Column(
      children: _prices.map((price) {
        return _buildPriceRow(
          context,
          price.serviceTypeName ?? 'Type inconnu',
          price.serviceName ?? 'Service inconnu',
          price.basePrice,
          price.premiumPrice,
          price.isAvailable,
          price.pricePerKg,
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des tarifs...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Une erreur est survenue',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPrices,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String serviceTypeName,
    String serviceName,
    double basePrice,
    double? premiumPrice,
    bool isAvailable,
    double? pricePerKg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.surface(context)
            : AppColors.textTertiary(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      serviceTypeName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Indisponible',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Prix
          Row(
            children: [
              // Prix Basic
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Basic',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${basePrice.toInt()} FCFA',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Prix Premium
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: premiumPrice != null
                        ? AppColors.secondary.withOpacity(0.1)
                        : AppColors.textTertiary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: 16,
                            color: premiumPrice != null
                                ? AppColors.secondary
                                : AppColors.textTertiary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: premiumPrice != null
                                  ? AppColors.secondary
                                  : AppColors.textTertiary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        premiumPrice != null
                            ? '${premiumPrice.toInt()} FCFA'
                            : 'N/A',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: premiumPrice != null
                              ? AppColors.textPrimary(context)
                              : AppColors.textTertiary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Prix au kg si disponible
          if (pricePerKg != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.scale,
                    size: 16,
                    color: AppColors.teal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Prix au kg: ${pricePerKg.toInt()} FCFA/kg',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.price_change_outlined,
              size: 64,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun tarif disponible',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les tarifs pour cet article seront bientôt disponibles',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

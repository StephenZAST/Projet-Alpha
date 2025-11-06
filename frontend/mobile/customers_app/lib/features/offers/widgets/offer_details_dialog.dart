import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/offer.dart';

/// 📖 Dialog Détails Offre - Alpha Client App
///
/// Affiche les détails complets d'une offre.
class OfferDetailsDialog extends StatelessWidget {
  final Offer offer;

  const OfferDetailsDialog({
    Key? key,
    required this.offer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                _buildHeader(context),
                const SizedBox(height: 24),

                // Réduction
                _buildDiscountSection(context),
                const SizedBox(height: 24),

                // Description
                if (offer.description != null && offer.description!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offer.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Conditions
                _buildConditionsSection(context),
                const SizedBox(height: 24),

                // Dates
                _buildDatesSection(context),
                const SizedBox(height: 24),

                // Actions
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📋 En-tête
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.accent.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.local_offer,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.name,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: offer.isValid
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  offer.isValid ? '✓ Valide' : '✗ Expirée',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: offer.isValid
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
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
    );
  }

  /// 💰 Section Réduction
  Widget _buildDiscountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réduction',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer.discountLabel,
                  style: AppTextStyles.display.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.discountTypeLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Économies possibles',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📋 Section Conditions
  Widget _buildConditionsSection(BuildContext context) {
    final conditions = <MapEntry<String, String>>[];

    if (offer.minPurchaseAmount != null && offer.minPurchaseAmount! > 0) {
      conditions.add(MapEntry(
        'Achat minimum',
        '${offer.minPurchaseAmount!.toStringAsFixed(2)}€',
      ));
    }

    if (offer.maxDiscountAmount != null && offer.maxDiscountAmount! > 0) {
      conditions.add(MapEntry(
        'Réduction maximale',
        '${offer.maxDiscountAmount!.toStringAsFixed(2)}€',
      ));
    }

    if (offer.pointsRequired != null && offer.pointsRequired! > 0) {
      conditions.add(MapEntry(
        'Points requis',
        '${offer.pointsRequired!.toStringAsFixed(0)} pts',
      ));
    }

    if (conditions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditions',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...conditions.map((condition) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    condition.key,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      condition.value,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// 📅 Section Dates
  Widget _buildDatesSection(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validité',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Du ${offer.startDate != null ? dateFormat.format(offer.startDate!) : 'N/A'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Au ${offer.endDate != null ? dateFormat.format(offer.endDate!) : 'N/A'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎯 Actions
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: offer.isSubscribed ? 'Abonné ✓' : 'S\'abonner',
            onPressed: offer.isSubscribed ? null : () => Navigator.pop(context),
            icon: offer.isSubscribed ? Icons.check : Icons.bookmark_outline,
          ),
        ),
      ],
    );
  }
}

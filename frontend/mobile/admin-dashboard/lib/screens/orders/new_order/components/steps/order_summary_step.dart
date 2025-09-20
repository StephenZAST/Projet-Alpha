import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import 'package:admin/models/enums.dart';
import 'order_summary_components.dart';
import 'dart:ui';

class OrderSummaryStep extends StatefulWidget {
  @override
  State<OrderSummaryStep> createState() => _OrderSummaryStepState();
}

class _OrderSummaryStepState extends State<OrderSummaryStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(isDark),
                  SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildClientSummary(isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildServiceSummary(isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildArticlesSummary(isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildExtraFieldsSummary(isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildTotalSection(isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepHeader(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récapitulatif de la Commande',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Vérifiez tous les détails avant validation',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Aperçu final',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSummary(bool isDark) {
    return Obx(() {
      final client = controller.clients
          .firstWhereOrNull((c) => c.id == controller.selectedClientId.value);
      final address = controller.clientAddresses
          .firstWhereOrNull((a) => a.id == controller.selectedAddressId.value);

      return SummarySection(
        title: 'Informations Client',
        icon: Icons.person,
        color: AppColors.primary,
        isDark: isDark,
        child: Column(
          children: [
            SummaryInfoRow(
              icon: Icons.person,
              label: 'Nom complet',
              value: '${client?.firstName ?? ''} ${client?.lastName ?? ''}',
              isDark: isDark,
            ),
            SummaryInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: client?.email ?? 'Non renseigné',
              isDark: isDark,
            ),
            SummaryInfoRow(
              icon: Icons.phone,
              label: 'Téléphone',
              value: client?.phone ?? 'Non renseigné',
              isDark: isDark,
            ),
            SummaryInfoRow(
              icon: Icons.location_on,
              label: 'Adresse',
              value: address?.fullAddress ?? 'Non renseignée',
              isDark: isDark,
              isMultiline: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildServiceSummary(bool isDark) {
    return Obx(() {
      final service = controller.services
          .firstWhereOrNull((s) => s.id == controller.selectedServiceId.value);

      return SummarySection(
        title: 'Service Sélectionné',
        icon: Icons.cleaning_services,
        color: AppColors.info,
        isDark: isDark,
        child: Column(
          children: [
            SummaryInfoRow(
              icon: Icons.label,
              label: 'Type de service',
              value: service?.name ?? 'Non sélectionné',
              isDark: isDark,
            ),
            if (service?.description != null)
              SummaryInfoRow(
                icon: Icons.description,
                label: 'Description',
                value: service!.description!,
                isDark: isDark,
                isMultiline: true,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildArticlesSummary(bool isDark) {
    return SummarySection(
      title: 'Articles Sélectionnés',
      icon: Icons.inventory,
      color: AppColors.accent,
      isDark: isDark,
      child: Obx(() {
        final items = controller.selectedArticleDetails;
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            message: 'Aucun article sélectionné',
            isDark: isDark,
          );
        }

        return Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            final bool isPremium = item['isPremium'] ?? false;
            final double unitPrice = isPremium
                ? (item['premiumPrice'] ?? item['basePrice'] ?? 0.0)
                : (item['basePrice'] ?? 0.0);
            final int quantity = item['quantity'] ?? 1;
            final double lineTotal = unitPrice * quantity;

            return Column(
              children: [
                if (index > 0) SizedBox(height: AppSpacing.sm),
                ModernArticleCard(
                  item: {
                    ...item,
                    'unitPrice': unitPrice,
                    'lineTotal': lineTotal,
                  },
                  isDark: isDark,
                ),
              ],
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildExtraFieldsSummary(bool isDark) {
    return Obx(() {
      final draft = controller.orderDraft.value;

      String? statusLabel;
      Color? statusColor;
      IconData? statusIcon;
      if (draft.status != null) {
        final statusEnum =
            OrderStatus.values.firstWhereOrNull((s) => s.name == draft.status);
        statusLabel = statusEnum?.label;
        statusColor = statusEnum?.color;
        statusIcon = statusEnum?.icon;
      }

      String? paymentLabel;
      if (draft.paymentMethod != null) {
        final paymentEnum = PaymentMethod.values
            .firstWhereOrNull((p) => p.name == draft.paymentMethod);
        paymentLabel = paymentEnum?.label;
      }

      String? recurrenceLabel;
      if (draft.recurrenceType != null) {
        switch (draft.recurrenceType) {
          case 'WEEKLY':
            recurrenceLabel = 'Hebdomadaire';
            break;
          case 'BIWEEKLY':
            recurrenceLabel = 'Toutes les 2 semaines';
            break;
          case 'MONTHLY':
            recurrenceLabel = 'Mensuelle';
            break;
          default:
            recurrenceLabel = 'Aucune';
        }
      }

      return SummarySection(
        title: 'Détails de la Commande',
        icon: Icons.settings,
        color: AppColors.warning,
        isDark: isDark,
        child: Column(
          children: [
            SummaryInfoRow(
              icon: Icons.schedule,
              label: 'Date de collecte',
              value: draft.collectionDate != null
                  ? draft.collectionDate!.toLocal().toString().split(' ')[0]
                  : 'Non définie',
              isDark: isDark,
            ),
            SummaryInfoRow(
              icon: Icons.local_shipping,
              label: 'Date de livraison',
              value: draft.deliveryDate != null
                  ? draft.deliveryDate!.toLocal().toString().split(' ')[0]
                  : 'Non définie',
              isDark: isDark,
            ),
            if (statusLabel != null)
              SummaryInfoRow(
                icon: statusIcon ?? Icons.flag,
                label: 'Statut',
                value: statusLabel,
                valueColor: statusColor,
                isDark: isDark,
              ),
            if (paymentLabel != null)
              SummaryInfoRow(
                icon: Icons.payment,
                label: 'Méthode de paiement',
                value: paymentLabel,
                isDark: isDark,
              ),
            if (draft.affiliateCode != null && draft.affiliateCode!.isNotEmpty)
              SummaryInfoRow(
                icon: Icons.card_giftcard,
                label: 'Code affilié',
                value: draft.affiliateCode!,
                isDark: isDark,
              ),
            if (recurrenceLabel != null && recurrenceLabel != 'Aucune')
              SummaryInfoRow(
                icon: Icons.repeat,
                label: 'Récurrence',
                value: recurrenceLabel,
                isDark: isDark,
              ),
            if (draft.nextRecurrenceDate != null &&
                draft.recurrenceType != null &&
                draft.recurrenceType != 'NONE')
              SummaryInfoRow(
                icon: Icons.event,
                label: 'Prochaine récurrence',
                value: draft.nextRecurrenceDate!
                    .toLocal()
                    .toString()
                    .split(' ')[0],
                isDark: isDark,
              ),
            if (draft.note != null && draft.note!.trim().isNotEmpty)
              SummaryInfoRow(
                icon: Icons.note_alt,
                label: 'Note',
                value: draft.note!,
                isDark: isDark,
                isMultiline: true,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTotalSection(bool isDark) {
    return Obx(() {
      final items = controller.getRecapOrderItems();
      final total = items.fold<double>(0, (sum, item) {
        final lineTotal = (item['lineTotal'] as num?)?.toDouble();
        if (lineTotal != null) return sum + lineTotal;
        final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0.0;
        final quantity = item['quantity'] is int
            ? item['quantity'] as int
            : (item['quantity'] as num?)?.toInt() ?? 1;
        return sum + (unitPrice * quantity);
      });

      return TotalCard(
        total: total,
        itemCount: items.length,
        isDark: isDark,
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/affiliate.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../widgets/shared/glass_button.dart';

class AffiliateDetailsDialog extends StatefulWidget {
  final AffiliateProfile affiliate;

  const AffiliateDetailsDialog({
    Key? key,
    required this.affiliate,
  }) : super(key: key);

  @override
  State<AffiliateDetailsDialog> createState() => _AffiliateDetailsDialogState();
}

class _AffiliateDetailsDialogState extends State<AffiliateDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AffiliatesController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller = Get.find<AffiliatesController>();
    
    // Charger les détails de l'affilié
    controller.selectAffiliate(widget.affiliate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 900,
        height: 700,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                  color: isDark 
                      ? AppColors.gray700.withOpacity(0.5)
                      : AppColors.gray200.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context, isDark),
                  _buildTabBar(context, isDark),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(context, isDark),
                        _buildCommissionsTab(context, isDark),
                        _buildReferralsTab(context, isDark),
                      ],
                    ),
                  ),
                  _buildActions(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.affiliate.status.color.withOpacity(0.1),
            widget.affiliate.status.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.affiliate.status.color.withOpacity(0.2),
                  widget.affiliate.status.color.withOpacity(0.1),
                ],
              ),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: widget.affiliate.status.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.handshake_outlined,
              size: 40,
              color: widget.affiliate.status.color,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.affiliate.fullName,
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  widget.affiliate.email,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildStatusBadge(widget.affiliate.status),
                    SizedBox(width: AppSpacing.md),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppRadius.radiusXS,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.affiliate.affiliateCode,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark 
                  ? AppColors.gray800.withOpacity(0.5)
                  : AppColors.gray100.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? AppColors.gray400 : AppColors.textMuted,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(
            icon: Icon(Icons.dashboard_outlined),
            text: 'Vue d\'ensemble',
          ),
          Tab(
            icon: Icon(Icons.account_balance_wallet_outlined),
            text: 'Commissions',
          ),
          Tab(
            icon: Icon(Icons.people_outline),
            text: 'Filleuls',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques principales
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Gagné',
                  widget.affiliate.formattedTotalEarned,
                  Icons.trending_up,
                  AppColors.success,
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Solde Commission',
                  widget.affiliate.formattedBalance,
                  Icons.account_balance_wallet,
                  AppColors.primary,
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Ce Mois',
                  widget.affiliate.formattedMonthlyEarnings,
                  Icons.calendar_today,
                  AppColors.info,
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Filleuls',
                  widget.affiliate.totalReferrals.toString(),
                  Icons.people,
                  AppColors.accent,
                  isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          
          // Informations détaillées
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Informations Personnelles',
                  [
                    _buildInfoRow('Nom complet', widget.affiliate.fullName, isDark),
                    _buildInfoRow('Email', widget.affiliate.email, isDark),
                    _buildInfoRow('Téléphone', widget.affiliate.phone, isDark),
                    _buildInfoRow('Date d\'inscription', 
                        _formatDate(widget.affiliate.createdAt), isDark),
                  ],
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildInfoCard(
                  'Configuration',
                  [
                    _buildInfoRow('Taux de commission', 
                        widget.affiliate.formattedCommissionRate, isDark),
                    _buildInfoRow('Statut', widget.affiliate.statusLabel, isDark),
                    _buildInfoRow('Actif', widget.affiliate.isActive ? 'Oui' : 'Non', isDark),
                    if (widget.affiliate.level != null)
                      _buildInfoRow('Niveau', widget.affiliate.level!.name, isDark),
                  ],
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionsTab(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Obx(() {
        if (controller.isLoadingCommissions.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: AppSpacing.md),
                Text('Chargement des commissions...'),
              ],
            ),
          );
        }

        if (controller.commissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Aucune commission trouvée',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.commissions.length,
          separatorBuilder: (context, index) => Divider(
            color: isDark 
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            final commission = controller.commissions[index];
            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: commission.status.color.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(
                  commission.status.icon,
                  color: commission.status.color,
                ),
              ),
              title: Text(
                commission.formattedAmount,
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Commande #${commission.orderId.substring(0, 8)}...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: commission.status.color.withOpacity(0.1),
                      borderRadius: AppRadius.radiusXS,
                    ),
                    child: Text(
                      commission.statusLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: commission.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _formatDate(commission.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildReferralsTab(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Obx(() {
        if (controller.affiliateReferrals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Aucun filleul trouvé',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Cet affilié n\'a pas encore de filleuls',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.affiliateReferrals.length,
          separatorBuilder: (context, index) => Divider(
            color: isDark 
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            final referral = controller.affiliateReferrals[index];
            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: referral.status.color.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: referral.status.color,
                ),
              ),
              title: Text(
                referral.fullName,
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referral.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Code: ${referral.affiliateCode}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(referral.status),
                  SizedBox(height: 2),
                  Text(
                    referral.formattedTotalEarned,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AffiliateStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: AppRadius.radiusXS,
        border: Border.all(
          color: status.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            color: status.color,
            size: 12,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            status.name,
            style: AppTextStyles.caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark 
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.affiliate.status == AffiliateStatus.PENDING) ...[
            GlassButton(
              label: 'Approuver',
              icon: Icons.check_circle,
              variant: GlassButtonVariant.success,
              onPressed: () {
                controller.updateAffiliateStatus(
                  widget.affiliate.id, 
                  AffiliateStatus.ACTIVE, 
                  true,
                );
                Navigator.of(context).pop();
              },
            ),
            SizedBox(width: AppSpacing.md),
            GlassButton(
              label: 'Rejeter',
              icon: Icons.cancel,
              variant: GlassButtonVariant.error,
              onPressed: () {
                controller.updateAffiliateStatus(
                  widget.affiliate.id, 
                  AffiliateStatus.SUSPENDED, 
                  false,
                );
                Navigator.of(context).pop();
              },
            ),
            SizedBox(width: AppSpacing.md),
          ],
          if (widget.affiliate.status == AffiliateStatus.ACTIVE) ...[
            GlassButton(
              label: 'Suspendre',
              icon: Icons.block,
              variant: GlassButtonVariant.warning,
              onPressed: () {
                controller.updateAffiliateStatus(
                  widget.affiliate.id, 
                  AffiliateStatus.SUSPENDED, 
                  false,
                );
                Navigator.of(context).pop();
              },
            ),
            SizedBox(width: AppSpacing.md),
          ],
          GlassButton(
            label: 'Fermer',
            icon: Icons.close,
            variant: GlassButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
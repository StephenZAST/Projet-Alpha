import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/loyalty_controller.dart';
import '../../../models/loyalty.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../utils/date_utils.dart';

class LoyaltyPointsTable extends StatelessWidget {
  const LoyaltyPointsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoyaltyController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: Column(
        children: [
          _buildTableHeader(context, isDark, controller),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.filteredLoyaltyPoints.length,
                  itemBuilder: (context, index) {
                    final loyaltyPoints =
                        controller.filteredLoyaltyPoints[index];
                    return _buildTableRow(
                      context,
                      isDark,
                      loyaltyPoints,
                      controller,
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(
    BuildContext context,
    bool isDark,
    LoyaltyController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray700.withOpacity(0.3)
            : AppColors.gray100.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.radiusMD.topLeft,
          topRight: AppRadius.radiusMD.topRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildHeaderCell(
              context,
              isDark,
              'Utilisateur',
              'name',
              controller,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell(
              context,
              isDark,
              'Points Actuels',
              'pointsBalance',
              controller,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell(
              context,
              isDark,
              'Total Gagné',
              'totalEarned',
              controller,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell(
              context,
              isDark,
              'Valeur FCFA',
              'value',
              controller,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell(
              context,
              isDark,
              'Membre depuis',
              'createdAt',
              controller,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Actions',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    bool isDark,
    String title,
    String field,
    LoyaltyController controller,
  ) {
    return InkWell(
      onTap: () => controller.changeSorting(field),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Obx(() {
            if (controller.sortBy.value == field) {
              return Icon(
                controller.sortOrder.value == 'asc'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
                color: AppColors.primary,
              );
            }
            return Icon(
              Icons.unfold_more,
              size: 16,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    bool isDark,
    LoyaltyPoints loyaltyPoints,
    LoyaltyController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Utilisateur
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loyaltyPoints.fullName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        loyaltyPoints.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.gray600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Points actuels
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: loyaltyPoints.hasPoints
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.gray500.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Text(
                    loyaltyPoints.formattedBalance,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: loyaltyPoints.hasPoints
                          ? AppColors.success
                          : AppColors.gray500,
                    ),
                  ),
                ),
                if (loyaltyPoints.canRedeem) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Peut échanger',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Total gagné
          Expanded(
            flex: 2,
            child: Text(
              loyaltyPoints.formattedTotalEarned,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          // Valeur FCFA
          Expanded(
            flex: 2,
            child: Text(
              loyaltyPoints.formattedConversionValue,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),

          // Date de création
          Expanded(
            flex: 2,
            child: Text(
              AppDateUtils.formatDate(loyaltyPoints.createdAt),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray600,
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              children: [
                GlassButton(
                  label: '',
                  icon: Icons.visibility_outlined,
                  variant: GlassButtonVariant.info,
                  size: GlassButtonSize.small,
                  onPressed: () =>
                      _showUserDetails(context, loyaltyPoints, controller),
                ),
                SizedBox(width: AppSpacing.xs),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? AppColors.gray300 : AppColors.gray600,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'add_points':
                        _showAddPointsDialog(
                            context, loyaltyPoints, controller);
                        break;
                      case 'deduct_points':
                        _showDeductPointsDialog(
                            context, loyaltyPoints, controller);
                        break;
                      case 'history':
                        _showPointHistory(context, loyaltyPoints, controller);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'add_points',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: AppColors.success),
                          SizedBox(width: AppSpacing.sm),
                          Text('Ajouter des points'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'deduct_points',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle_outline,
                              color: AppColors.warning),
                          SizedBox(width: AppSpacing.sm),
                          Text('Déduire des points'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history, color: AppColors.info),
                          SizedBox(width: AppSpacing.sm),
                          Text('Voir l\'historique'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(
    BuildContext context,
    LoyaltyPoints loyaltyPoints,
    LoyaltyController controller,
  ) {
    controller.selectLoyaltyPoints(loyaltyPoints);

    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppRadius.radiusMD,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loyaltyPoints.fullName,
                          style: AppTextStyles.h3,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          loyaltyPoints.email,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),

              // Statistiques des points
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Points Actuels',
                      loyaltyPoints.formattedBalance,
                      AppColors.success,
                      Icons.stars,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Total Gagné',
                      loyaltyPoints.formattedTotalEarned,
                      AppColors.primary,
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Valeur FCFA',
                      loyaltyPoints.formattedConversionValue,
                      AppColors.warning,
                      Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.xl),

              // Historique récent
              Text(
                'Historique Récent',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.md),

              Container(
                height: 200,
                child: Obx(() {
                  if (controller.userPointHistory.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune transaction trouvée',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.userPointHistory.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.userPointHistory[index];
                      return ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: transaction.type.color.withOpacity(0.1),
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Icon(
                            transaction.type.icon,
                            color: transaction.type.color,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          transaction.formattedPoints,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: transaction.type.color,
                          ),
                        ),
                        subtitle: Text(
                          '${transaction.sourceLabel} • ${AppDateUtils.formatDateTime(transaction.createdAt)}',
                          style: AppTextStyles.bodySmall,
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: AppSpacing.xl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Fermer',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Voir Historique Complet',
                      variant: GlassButtonVariant.primary,
                      onPressed: () {
                        Get.back();
                        _showPointHistory(context, loyaltyPoints, controller);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddPointsDialog(
    BuildContext context,
    LoyaltyPoints loyaltyPoints,
    LoyaltyController controller,
  ) {
    final pointsController = TextEditingController();
    final referenceController = TextEditingController();
    PointSource selectedSource = PointSource.REWARD;

    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ajouter des Points',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Utilisateur: ${loyaltyPoints.fullName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nombre de points',
                  hintText: 'Ex: 100',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<PointSource>(
                value: selectedSource,
                decoration: InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(),
                ),
                items: PointSource.values
                    .map((source) => DropdownMenuItem(
                          value: source,
                          child: Text(source.name == 'ORDER'
                              ? 'Commande'
                              : source.name == 'REFERRAL'
                                  ? 'Parrainage'
                                  : 'Récompense'),
                        ))
                    .toList(),
                onChanged: (value) => selectedSource = value!,
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: referenceController,
                decoration: InputDecoration(
                  labelText: 'Référence (optionnel)',
                  hintText: 'ID de commande, etc.',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Ajouter',
                      variant: GlassButtonVariant.success,
                      onPressed: () {
                        final points = int.tryParse(pointsController.text);
                        if (points != null && points > 0) {
                          controller.addPointsToUser(
                            loyaltyPoints.userId,
                            points,
                            selectedSource,
                            referenceController.text.isNotEmpty
                                ? referenceController.text
                                : 'MANUAL_ADD',
                          );
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeductPointsDialog(
    BuildContext context,
    LoyaltyPoints loyaltyPoints,
    LoyaltyController controller,
  ) {
    final pointsController = TextEditingController();
    final referenceController = TextEditingController();
    PointSource selectedSource = PointSource.REWARD;

    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Déduire des Points',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Utilisateur: ${loyaltyPoints.fullName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Points disponibles: ${loyaltyPoints.formattedBalance}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nombre de points à déduire',
                  hintText: 'Max: ${loyaltyPoints.pointsBalance}',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<PointSource>(
                value: selectedSource,
                decoration: InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(),
                ),
                items: PointSource.values
                    .map((source) => DropdownMenuItem(
                          value: source,
                          child: Text(source.name == 'ORDER'
                              ? 'Commande'
                              : source.name == 'REFERRAL'
                                  ? 'Parrainage'
                                  : 'Récompense'),
                        ))
                    .toList(),
                onChanged: (value) => selectedSource = value!,
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: referenceController,
                decoration: InputDecoration(
                  labelText: 'Référence (optionnel)',
                  hintText: 'ID de récompense, etc.',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Déduire',
                      variant: GlassButtonVariant.warning,
                      onPressed: () {
                        final points = int.tryParse(pointsController.text);
                        if (points != null &&
                            points > 0 &&
                            points <= loyaltyPoints.pointsBalance) {
                          controller.deductPointsFromUser(
                            loyaltyPoints.userId,
                            points,
                            selectedSource,
                            referenceController.text.isNotEmpty
                                ? referenceController.text
                                : 'MANUAL_DEDUCT',
                          );
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPointHistory(
    BuildContext context,
    LoyaltyPoints loyaltyPoints,
    LoyaltyController controller,
  ) {
    controller.fetchUserPointHistory(loyaltyPoints.userId);

    Get.dialog(
      Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(
                'Historique des Points - ${loyaltyPoints.fullName}',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Obx(() {
                  if (controller.userPointHistory.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune transaction trouvée',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.userPointHistory.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.userPointHistory[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: transaction.type.color.withOpacity(0.1),
                              borderRadius: AppRadius.radiusSM,
                            ),
                            child: Icon(
                              transaction.type.icon,
                              color: transaction.type.color,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            transaction.formattedPoints,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: transaction.type.color,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${transaction.typeLabel} • ${transaction.sourceLabel}',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                AppDateUtils.formatDateTime(
                                    transaction.createdAt),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.source.color.withOpacity(0.1),
                              borderRadius: AppRadius.radiusSM,
                            ),
                            child: Text(
                              transaction.sourceLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: transaction.source.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

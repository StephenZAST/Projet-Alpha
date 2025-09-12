import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class OfferFilters extends StatelessWidget {
  final String searchQuery;
  final String? selectedStatus;
  final String? selectedType;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback onClearFilters;

  const OfferFilters({
    Key? key,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedType,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Première ligne : Recherche
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSearchField(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              if (searchQuery.isNotEmpty || selectedStatus != null || selectedType != null)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: onClearFilters,
                ),
            ],
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Deuxième ligne : Filtres
          Row(
            children: [
              Expanded(
                child: _buildStatusFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildTypeFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildDateRangeFilter(context, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher une offre...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedStatus,
        decoration: InputDecoration(
          labelText: 'Statut',
          labelStyle: TextStyle(
            color: isDark ? AppColors.gray300 : AppColors.gray600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text('Tous les statuts'),
          ),
          DropdownMenuItem(
            value: 'active',
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Actives'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'inactive',
            child: Row(
              children: [
                Icon(Icons.cancel, size: 16, color: AppColors.error),
                SizedBox(width: AppSpacing.xs),
                Text('Inactives'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'expired',
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.warning),
                SizedBox(width: AppSpacing.xs),
                Text('Expirées'),
              ],
            ),
          ),
        ],
        onChanged: onStatusChanged,
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedType,
        decoration: InputDecoration(
          labelText: 'Type de remise',
          labelStyle: TextStyle(
            color: isDark ? AppColors.gray300 : AppColors.gray600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text('Tous les types'),
          ),
          DropdownMenuItem(
            value: 'PERCENTAGE',
            child: Row(
              children: [
                Icon(Icons.percent, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Pourcentage'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'FIXED_AMOUNT',
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Montant fixe'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'POINTS_EXCHANGE',
            child: Row(
              children: [
                Icon(Icons.star, size: 16, color: AppColors.warning),
                SizedBox(width: AppSpacing.xs),
                Text('Échange points'),
              ],
            ),
          ),
        ],
        onChanged: onTypeChanged,
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implémenter le sélecteur de plage de dates
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Filtre par date - À implémenter')),
          );
        },
        borderRadius: AppRadius.radiusMD,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Période',
                style: TextStyle(
                  color: isDark ? AppColors.gray300 : AppColors.gray600,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_drop_down,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
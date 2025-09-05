import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../models/affiliate.dart';

class AffiliateFilters extends StatelessWidget {
  const AffiliateFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliatesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusMD,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.gray800.withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: isDark 
                    ? AppColors.gray700.withOpacity(0.3)
                    : AppColors.gray200.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Filtres et Recherche',
                      style: AppTextStyles.h4.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                    Spacer(),
                    Obx(() {
                      final hasFilters = controller.searchQuery.value.isNotEmpty || 
                                       controller.selectedStatus.value != null;
                      
                      if (!hasFilters) return SizedBox.shrink();
                      
                      return TextButton.icon(
                        onPressed: () {
                          controller.searchQuery.value = '';
                          controller.selectedStatus.value = null;
                        },
                        icon: Icon(Icons.clear_all, size: 16),
                        label: Text('Effacer'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      );
                    }),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    // Barre de recherche
                    Expanded(
                      flex: 2,
                      child: _buildSearchField(controller, isDark),
                    ),
                    SizedBox(width: AppSpacing.md),
                    
                    // Filtre par statut
                    Expanded(
                      child: _buildStatusFilter(controller, isDark),
                    ),
                    SizedBox(width: AppSpacing.md),
                    
                    // Tri
                    Expanded(
                      child: _buildSortFilter(controller, isDark),
                    ),
                  ],
                ),
                
                // Indicateurs de filtres actifs
                SizedBox(height: AppSpacing.sm),
                _buildActiveFilters(controller, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(AffiliatesController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isDark 
              ? AppColors.gray600.withOpacity(0.2)
              : AppColors.gray300.withOpacity(0.3),
        ),
      ),
      child: TextField(
        onChanged: controller.searchAffiliates,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, email ou code...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: AppColors.primary.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(AffiliatesController controller, bool isDark) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: controller.selectedStatus.value != null
              ? controller.selectedStatus.value!.color.withOpacity(0.3)
              : (isDark 
                  ? AppColors.gray600.withOpacity(0.2)
                  : AppColors.gray300.withOpacity(0.3)),
        ),
      ),
      child: DropdownButtonFormField<AffiliateStatus?>(
        value: controller.selectedStatus.value,
        decoration: InputDecoration(
          labelText: 'Statut',
          prefixIcon: Icon(
            Icons.filter_alt_outlined,
            color: AppColors.accent.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
        ),
        items: [
          DropdownMenuItem<AffiliateStatus?>(
            value: null,
            child: Text(
              'Tous les statuts',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          ...AffiliateStatus.values.map((status) {
            return DropdownMenuItem<AffiliateStatus?>(
              value: status,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.1),
                      borderRadius: AppRadius.radiusXS,
                    ),
                    child: Icon(
                      status.icon,
                      color: status.color,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    status.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        onChanged: controller.filterByStatus,
        dropdownColor: isDark ? AppColors.gray800 : Colors.white,
      ),
    ));
  }

  Widget _buildSortFilter(AffiliatesController controller, bool isDark) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: isDark 
              ? AppColors.gray600.withOpacity(0.2)
              : AppColors.gray300.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.sortBy.value,
        decoration: InputDecoration(
          labelText: 'Trier par',
          prefixIcon: Icon(
            controller.sortOrder.value == 'asc' 
                ? Icons.arrow_upward 
                : Icons.arrow_downward,
            color: AppColors.info.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
        ),
        items: [
          DropdownMenuItem(
            value: 'createdAt',
            child: Text(
              'Date de création',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'name',
            child: Text(
              'Nom',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'totalEarned',
            child: Text(
              'Total gagné',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'commissionBalance',
            child: Text(
              'Solde commission',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.changeSorting(value);
          }
        },
        dropdownColor: isDark ? AppColors.gray800 : Colors.white,
      ),
    ));
  }

  Widget _buildActiveFilters(AffiliatesController controller, bool isDark) {
    return Obx(() {
      final filters = <Widget>[];
      
      // Filtre de recherche
      if (controller.searchQuery.value.isNotEmpty) {
        filters.add(
          _buildFilterChip(
            label: 'Recherche: "${controller.searchQuery.value}"',
            color: AppColors.primary,
            onRemove: () => controller.searchQuery.value = '',
            isDark: isDark,
          ),
        );
      }
      
      // Filtre de statut
      if (controller.selectedStatus.value != null) {
        filters.add(
          _buildFilterChip(
            label: 'Statut: ${controller.selectedStatus.value!.name}',
            color: controller.selectedStatus.value!.color,
            onRemove: () => controller.selectedStatus.value = null,
            isDark: isDark,
          ),
        );
      }
      
      if (filters.isEmpty) return SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres actifs:',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: filters,
          ),
        ],
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required Color color,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusXS,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
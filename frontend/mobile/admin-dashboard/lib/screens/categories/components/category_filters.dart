import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class CategoryFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;

  const CategoryFilters({
    Key? key,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<CategoryFilters> createState() => _CategoryFiltersState();
}

class _CategoryFiltersState extends State<CategoryFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              if (_searchController.text.isNotEmpty || _selectedStatus != null)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    _selectedStatus = null;
                    widget.onSearchChanged('');
                    widget.onStatusChanged(null);
                    widget.onClearFilters();
                    setState(() {});
                  },
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
                child: _buildSortFilter(context, isDark),
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
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher une catégorie...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
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
        value: _selectedStatus,
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
        ],
        onChanged: (value) {
          setState(() {
            _selectedStatus = value;
          });
          widget.onStatusChanged(value);
        },
      ),
    );
  }

  Widget _buildSortFilter(BuildContext context, bool isDark) {
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
        decoration: InputDecoration(
          labelText: 'Trier par',
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
            value: 'name_asc',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Nom (A-Z)'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'name_desc',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Nom (Z-A)'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'articles_desc',
            child: Row(
              children: [
                Icon(Icons.trending_down, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Plus d\'articles'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'articles_asc',
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: AppColors.warning),
                SizedBox(width: AppSpacing.xs),
                Text('Moins d\'articles'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'date_desc',
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.info),
                SizedBox(width: AppSpacing.xs),
                Text('Plus récentes'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          // TODO: Implémenter le tri
        },
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
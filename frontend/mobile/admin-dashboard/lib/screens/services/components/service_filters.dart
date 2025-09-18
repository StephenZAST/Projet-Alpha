import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class ServiceFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;

  const ServiceFilters({
    Key? key,
    required this.onSearchChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<ServiceFilters> createState() => _ServiceFiltersState();
}

class _ServiceFiltersState extends State<ServiceFilters> {
  final TextEditingController _searchController = TextEditingController();

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
          // Ligne de recherche
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSearchField(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              if (_searchController.text.isNotEmpty)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                    widget.onClearFilters();
                    setState(() {});
                  },
                ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Ligne des filtres de tri
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSortFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 1,
                child: Container(), // Espace vide pour équilibrer le layout
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
          hintText: 'Rechercher un service...',
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
            value: 'recent',
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Plus récents'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'oldest',
            child: Row(
              children: [
                Icon(Icons.history, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Plus anciens'),
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
}

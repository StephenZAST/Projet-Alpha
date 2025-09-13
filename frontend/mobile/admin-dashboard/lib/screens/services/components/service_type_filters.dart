import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class ServiceTypeFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onPricingTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;

  const ServiceTypeFilters({
    Key? key,
    required this.onSearchChanged,
    required this.onPricingTypeChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<ServiceTypeFilters> createState() => _ServiceTypeFiltersState();
}

class _ServiceTypeFiltersState extends State<ServiceTypeFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPricingType;
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
              if (_searchController.text.isNotEmpty || 
                  _selectedPricingType != null || 
                  _selectedStatus != null)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    _selectedPricingType = null;
                    _selectedStatus = null;
                    widget.onSearchChanged('');
                    widget.onPricingTypeChanged(null);
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
                child: _buildPricingTypeFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatusFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSortFilter(context, isDark),
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
          hintText: 'Rechercher un type de service...',
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

  Widget _buildPricingTypeFilter(BuildContext context, bool isDark) {
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
        value: _selectedPricingType,
        decoration: InputDecoration(
          labelText: 'Type de tarification',
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
            value: 'FIXED',
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Prix fixe'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'WEIGHT_BASED',
            child: Row(
              children: [
                Icon(Icons.scale, size: 16, color: AppColors.warning),
                SizedBox(width: AppSpacing.xs),
                Text('Au poids'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'SUBSCRIPTION',
            child: Row(
              children: [
                Icon(Icons.subscriptions, size: 16, color: AppColors.info),
                SizedBox(width: AppSpacing.xs),
                Text('Abonnement'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'CUSTOM',
            child: Row(
              children: [
                Icon(Icons.tune, size: 16, color: AppColors.violet),
                SizedBox(width: AppSpacing.xs),
                Text('Personnalisé'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedPricingType = value;
          });
          widget.onPricingTypeChanged(value);
        },
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
                Text('Actifs'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'inactive',
            child: Row(
              children: [
                Icon(Icons.cancel, size: 16, color: AppColors.error),
                SizedBox(width: AppSpacing.xs),
                Text('Inactifs'),
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
            value: 'pricing_type',
            child: Row(
              children: [
                Icon(Icons.category, size: 16, color: AppColors.info),
                SizedBox(width: AppSpacing.xs),
                Text('Par type de tarification'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'status',
            child: Row(
              children: [
                Icon(Icons.toggle_on, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Par statut'),
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
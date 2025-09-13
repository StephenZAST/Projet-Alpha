import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class CoupleFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onServiceTypeChanged;
  final ValueChanged<bool?> onAvailabilityChanged;
  final VoidCallback onClearFilters;

  const CoupleFilters({
    Key? key,
    required this.onSearchChanged,
    required this.onServiceTypeChanged,
    required this.onAvailabilityChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<CoupleFilters> createState() => _CoupleFiltersState();
}

class _CoupleFiltersState extends State<CoupleFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedServiceType;
  bool? _selectedAvailability;

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
                  _selectedServiceType != null || 
                  _selectedAvailability != null)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    _selectedServiceType = null;
                    _selectedAvailability = null;
                    widget.onSearchChanged('');
                    widget.onServiceTypeChanged(null);
                    widget.onAvailabilityChanged(null);
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
                child: _buildServiceTypeFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildAvailabilityFilter(context, isDark),
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
          hintText: 'Rechercher un couple service/article...',
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

  Widget _buildServiceTypeFilter(BuildContext context, bool isDark) {
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
        value: _selectedServiceType,
        decoration: InputDecoration(
          labelText: 'Type de service',
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
            _selectedServiceType = value;
          });
          widget.onServiceTypeChanged(value);
        },
      ),
    );
  }

  Widget _buildAvailabilityFilter(BuildContext context, bool isDark) {
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
      child: DropdownButtonFormField<bool>(
        value: _selectedAvailability,
        decoration: InputDecoration(
          labelText: 'Disponibilité',
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
            child: Text('Tous'),
          ),
          DropdownMenuItem(
            value: true,
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Disponibles'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: false,
            child: Row(
              children: [
                Icon(Icons.cancel, size: 16, color: AppColors.error),
                SizedBox(width: AppSpacing.xs),
                Text('Indisponibles'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedAvailability = value;
          });
          widget.onAvailabilityChanged(value);
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
            value: 'service_name_asc',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Service (A-Z)'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'article_name_asc',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Article (A-Z)'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'price_asc',
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: AppColors.info),
                SizedBox(width: AppSpacing.xs),
                Text('Prix croissant'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'price_desc',
            child: Row(
              children: [
                Icon(Icons.trending_down, size: 16, color: AppColors.warning),
                SizedBox(width: AppSpacing.xs),
                Text('Prix décroissant'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'availability',
            child: Row(
              children: [
                Icon(Icons.toggle_on, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Par disponibilité'),
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
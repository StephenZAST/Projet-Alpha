import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../controllers/service_type_controller.dart';

class ServiceFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<double?>? onPriceRangeChanged;
  final VoidCallback onClearFilters;

  const ServiceFilters({
    Key? key,
    required this.onSearchChanged,
    required this.onTypeChanged,
    this.onPriceRangeChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<ServiceFilters> createState() => _ServiceFiltersState();
}

class _ServiceFiltersState extends State<ServiceFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTypeId;
  RangeValues _priceRange = RangeValues(0, 50000);
  bool _showPriceFilter = false;

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
                  _selectedTypeId != null ||
                  _showPriceFilter)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    _selectedTypeId = null;
                    _showPriceFilter = false;
                    widget.onSearchChanged('');
                    widget.onTypeChanged(null);
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
                child: _buildTypeFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildPriceRangeToggle(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSortFilter(context, isDark),
              ),
            ],
          ),

          // Filtre de prix (conditionnel)
          if (_showPriceFilter) ...[
            SizedBox(height: AppSpacing.md),
            _buildPriceRangeSlider(context, isDark),
          ],
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
      child: GetBuilder<ServiceTypeController>(
        builder: (serviceTypeController) {
          return DropdownButtonFormField<String>(
            value: _selectedTypeId,
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
              ...serviceTypeController.serviceTypes.map((type) {
                return DropdownMenuItem(
                  value: type.id,
                  child: Row(
                    children: [
                      Icon(Icons.category, size: 16, color: AppColors.primary),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          type.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTypeId = value;
              });
              widget.onTypeChanged(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildPriceRangeToggle(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: _showPriceFilter
              ? AppColors.primary.withOpacity(0.5)
              : isDark
                  ? AppColors.gray700.withOpacity(0.3)
                  : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _showPriceFilter = !_showPriceFilter;
          });
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
                Icons.tune_outlined,
                color: _showPriceFilter
                    ? AppColors.primary
                    : isDark
                        ? AppColors.gray400
                        : AppColors.gray500,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Prix',
                style: TextStyle(
                  color: _showPriceFilter
                      ? AppColors.primary
                      : isDark
                          ? AppColors.gray300
                          : AppColors.gray600,
                  fontSize: 16,
                  fontWeight:
                      _showPriceFilter ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Spacer(),
              Icon(
                _showPriceFilter ? Icons.expand_less : Icons.expand_more,
                color: _showPriceFilter
                    ? AppColors.primary
                    : isDark
                        ? AppColors.gray400
                        : AppColors.gray500,
              ),
            ],
          ),
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
            value: 'price_asc',
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Prix croissant'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'price_desc',
            child: Row(
              children: [
                Icon(Icons.trending_down, size: 16, color: AppColors.error),
                SizedBox(width: AppSpacing.xs),
                Text('Prix décroissant'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'type',
            child: Row(
              children: [
                Icon(Icons.category, size: 16, color: AppColors.info),
                SizedBox(width: AppSpacing.xs),
                Text('Par type'),
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

  Widget _buildPriceRangeSlider(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.3)
            : AppColors.white.withOpacity(0.5),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fourchette de prix',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                '${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} FCFA',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 50000,
            divisions: 100,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
            onChangeEnd: (RangeValues values) {
              if (widget.onPriceRangeChanged != null) {
                widget.onPriceRangeChanged!(values.start);
              }
            },
          ),
        ],
      ),
    );
  }
}

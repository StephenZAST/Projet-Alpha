import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../controllers/category_controller.dart';

class ArticleFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<double?> onPriceRangeChanged;
  final VoidCallback onClearFilters;

  const ArticleFilters({
    Key? key,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onPriceRangeChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<ArticleFilters> createState() => _ArticleFiltersState();
}

class _ArticleFiltersState extends State<ArticleFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  RangeValues _priceRange = RangeValues(0, 100000);
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
                  _selectedCategoryId != null || 
                  _showPriceFilter)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    _selectedCategoryId = null;
                    _showPriceFilter = false;
                    widget.onSearchChanged('');
                    widget.onCategoryChanged(null);
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
                child: _buildCategoryFilter(context, isDark),
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
          hintText: 'Rechercher un article...',
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

  Widget _buildCategoryFilter(BuildContext context, bool isDark) {
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
      child: GetBuilder<CategoryController>(
        builder: (categoryController) {
          return DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Catégorie',
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
                child: Text('Toutes les catégories'),
              ),
              ...categoryController.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(Icons.folder, size: 16, color: AppColors.primary),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          category.name,
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
                _selectedCategoryId = value;
              });
              widget.onCategoryChanged(value);
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
                  fontWeight: _showPriceFilter ? FontWeight.w600 : FontWeight.normal,
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
            max: 100000,
            divisions: 100,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
            onChangeEnd: (RangeValues values) {
              widget.onPriceRangeChanged(values.start);
            },
          ),
        ],
      ),
    );
  }
}
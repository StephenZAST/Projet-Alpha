import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../controllers/category_controller.dart';

class ArticleFiltersSafe extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onClearFilters;

  const ArticleFiltersSafe({
    Key? key,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<ArticleFiltersSafe> createState() => _ArticleFiltersSafeState();
}

class _ArticleFiltersSafeState extends State<ArticleFiltersSafe> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;

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
                  _selectedCategoryId != null)
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    _selectedCategoryId = null;
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
      child: _buildSafeCategoryDropdown(isDark),
    );
  }

  Widget _buildSafeCategoryDropdown(bool isDark) {
    try {
      // Vérifier si le CategoryController est disponible
      if (!Get.isRegistered<CategoryController>()) {
        return _buildFallbackDropdown(isDark, 'Catégorie', 'Contrôleur non disponible');
      }

      return GetBuilder<CategoryController>(
        builder: (categoryController) {
          try {
            // Protection contre null/état non initialisé
            if (categoryController.isLoading.value) {
              return _buildFallbackDropdown(isDark, 'Catégorie', 'Chargement...');
            }

            if (categoryController.hasError.value) {
              return _buildFallbackDropdown(isDark, 'Catégorie', 'Erreur de chargement');
            }

            // Construire les items de manière sécurisée
            List<DropdownMenuItem<String>> items = [];
            
            // Item par défaut
            items.add(DropdownMenuItem(
              value: null,
              child: Text(
                'Toutes les catégories',
                style: TextStyle(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ));

            // Ajouter les catégories si disponibles
            if (categoryController.categories.isNotEmpty) {
              for (var category in categoryController.categories) {
                items.add(DropdownMenuItem(
                  value: category.id,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 200), // Contrainte de largeur fixe
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder, size: 16, color: AppColors.primary),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? AppColors.textLight : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
              }
            }

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
              items: items,
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
                widget.onCategoryChanged(value);
              },
            );
          } catch (e) {
            print('[ArticleFiltersSafe] Error in category dropdown: $e');
            return _buildFallbackDropdown(isDark, 'Catégorie', 'Erreur');
          }
        },
      );
    } catch (e) {
      print('[ArticleFiltersSafe] Error building category filter: $e');
      return _buildFallbackDropdown(isDark, 'Catégorie', 'Erreur système');
    }
  }

  Widget _buildFallbackDropdown(bool isDark, String label, String message) {
    return DropdownButtonFormField<String>(
      value: null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.gray300 : AppColors.gray600,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            message,
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
        ),
      ],
      onChanged: null,
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
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_by_alpha, size: 16, color: AppColors.primary),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Nom (A-Z)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'name_desc',
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_by_alpha, size: 16, color: AppColors.primary),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Nom (Z-A)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'date_desc',
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.info),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Plus récents',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'date_asc',
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 16, color: AppColors.warning),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Plus anciens',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        onChanged: (value) {
          // TODO: Implémenter le tri
          print('[ArticleFiltersSafe] Sort changed to: $value');
        },
      ),
    );
  }
}
import 'package:admin/models/article.dart';
import 'package:admin/screens/articles/components/article_form_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/article_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/menu_app_controller.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import '../../utils/controller_manager.dart';
import 'components/article_stats_grid.dart';
import 'components/article_table.dart';
import 'components/article_filters_safe.dart';

class ArticlesScreenSafe extends StatefulWidget {
  const ArticlesScreenSafe({Key? key}) : super(key: key);

  @override
  State<ArticlesScreenSafe> createState() => _ArticlesScreenSafeState();
}

class _ArticlesScreenSafeState extends State<ArticlesScreenSafe> {
  ArticleController? controller;
  bool isInitialized = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('[ArticlesScreenSafe] initState: Initialisation');
    _safeInitializeControllers();
  }

  Future<void> _safeInitializeControllers() async {
    try {
      // Attendre un frame pour s'assurer que le widget est monté
      await Future.delayed(Duration.zero);
      
      if (!mounted) return;

      // Initialiser les contrôleurs de manière sécurisée
      await _initializeControllers();
      
      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      print('[ArticlesScreenSafe] Erreur lors de l\'initialisation: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isInitialized = true; // Pour afficher l'erreur
        });
      }
    }
  }

  Future<void> _initializeControllers() async {
    try {
      // Utiliser le gestionnaire centralisé
      ControllerManager.initializeAllControllers();
      
      // Récupérer le contrôleur de manière sécurisée
      controller = ControllerManager.safeGet<ArticleController>();
      print('[ArticlesScreenSafe] ArticleController récupéré via ControllerManager');

      // Vérifier l'état des contrôleurs
      ControllerManager.checkControllersStatus();

      // Forcer le rechargement des données si nécessaire
      if (controller != null && controller!.articles.isEmpty) {
        await controller!.fetchArticles();
      }
    } catch (e) {
      print('[ArticlesScreenSafe] Erreur lors de l\'initialisation des contrôleurs: $e');
      // Fallback vers l'ancienne méthode en cas d'erreur
      await _fallbackInitialization();
    }
  }

  Future<void> _fallbackInitialization() async {
    try {
      if (Get.isRegistered<ArticleController>()) {
        controller = Get.find<ArticleController>();
      } else {
        controller = Get.put(ArticleController(), permanent: true);
      }
      
      if (!Get.isRegistered<CategoryController>()) {
        Get.put(CategoryController(), permanent: true);
      }
      
      // Attendre que les données soient chargées
      if (controller != null && controller!.articles.isEmpty) {
        await controller!.fetchArticles();
      }
      
      print('[ArticlesScreenSafe] Fallback initialization completed');
    } catch (e) {
      print('[ArticlesScreenSafe] Fallback initialization failed: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    print('[ArticlesScreenSafe] dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Afficher un état de chargement pendant l'initialisation
    if (!isInitialized) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text(
                'Initialisation des articles...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Afficher l'erreur si l'initialisation a échoué
    if (errorMessage != null || controller == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Erreur d\'initialisation',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                errorMessage ?? 'Contrôleur non disponible',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Réessayer',
                icon: Icons.refresh,
                variant: GlassButtonVariant.primary,
                onPressed: () {
                  setState(() {
                    isInitialized = false;
                    errorMessage = null;
                    controller = null;
                  });
                  _safeInitializeControllers();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec hauteur flexible
              Flexible(
                flex: 0,
                child: _buildHeader(context, isDark),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal scrollable
              Expanded(
                child: _buildMainContent(context, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    // Vérification de sécurité supplémentaire
    if (controller == null) {
      return Center(
        child: Text(
          'Contrôleur non disponible',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques avec gestion d'erreur
          _buildStatsSection(isDark),
          SizedBox(height: AppSpacing.lg),

          // Filtres et recherche
          _buildFiltersSection(),
          SizedBox(height: AppSpacing.md),

          // Table des articles avec hauteur contrainte
          _buildArticlesTable(context, isDark),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    try {
      return Obx(() => ArticleStatsGrid(
            totalArticles: controller?.articles.length ?? 0,
            activeArticles: controller?.articles.length ?? 0,
            categoriesCount: _getCategoriesCount(),
            averagePrice: _getAveragePrice(),
          ));
    } catch (e) {
      print('[ArticlesScreenSafe] Error in stats section: $e');
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'Erreur lors du chargement des statistiques',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildFiltersSection() {
    try {
      return ArticleFiltersSafe(
        onSearchChanged: controller?.searchArticles ?? (String value) {},
        onCategoryChanged: (categoryId) {
          controller?.setSelectedCategory(categoryId);
        },
        onClearFilters: () {
          controller?.setSelectedCategory(null);
          controller?.searchArticles('');
        },
      );
    } catch (e) {
      print('[ArticlesScreenSafe] Error in filters section: $e');
      return Container(
        height: 60,
        child: Center(
          child: Text(
            'Erreur lors du chargement des filtres',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildArticlesTable(BuildContext context, bool isDark) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: GetBuilder<ArticleController>(
        init: controller,
        builder: (ctrl) {
          if (ctrl.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Chargement des articles...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (ctrl.articles.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          try {
            return ArticleTable(
              articles: ctrl.articles,
              onEdit: (article) => Get.dialog(
                ArticleFormDialog(article: article),
                barrierDismissible: false,
              ),
              onDelete: _showDeleteDialog,
              onDuplicate: (article) => _duplicateArticle(article),
            );
          } catch (e) {
            print('[ArticlesScreenSafe] Error in article table: $e');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Erreur lors de l\'affichage des articles',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  GlassButton(
                    label: 'Réessayer',
                    icon: Icons.refresh,
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => controller?.fetchArticles(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Articles',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            GetBuilder<ArticleController>(
              init: controller,
              builder: (ctrl) {
                return Text(
                  ctrl.isLoading.value
                      ? 'Chargement...'
                      : '${ctrl.articles.length} article${ctrl.articles.length > 1 ? 's' : ''} • ${_getCategoriesCount()} catégorie${_getCategoriesCount() > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                );
              },
            ),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Catégories',
              icon: Icons.category_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () {
                try {
                  final menuController = Get.find<MenuAppController>();
                  menuController.goToCategories();
                } catch (e) {
                  print('[ArticlesScreenSafe] Error navigating to categories: $e');
                }
              },
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Nouvel Article',
              icon: Icons.add_circle_outline,
              variant: GlassButtonVariant.primary,
              onPressed: () => Get.dialog(
                ArticleFormDialog(),
                barrierDismissible: false,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: () => controller?.fetchArticles(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun article trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller?.selectedCategory.value != null
                ? 'Aucun article ne correspond à vos critères de recherche'
                : 'Aucun article n\'est encore créé dans le système',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          if (controller?.selectedCategory.value != null)
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                controller?.setSelectedCategory(null);
                controller?.searchArticles('');
              },
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Article article) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48, color: AppColors.warning),
              SizedBox(height: AppSpacing.md),
              Text(
                'Confirmer la suppression',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Êtes-vous sûr de vouloir supprimer l\'article "${article.name}" ?',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
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
                      label: 'Supprimer',
                      variant: GlassButtonVariant.error,
                      onPressed: () {
                        Get.back();
                        controller?.deleteArticle(article.id);
                        _showSuccessSnackbar('Article supprimé avec succès');
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

  void _duplicateArticle(Article article) {
    Get.dialog(
      ArticleFormDialog(
        article: Article(
          id: '', // Nouvel ID sera généré
          name: '${article.name} (Copie)',
          description: article.description,
          basePrice: article.basePrice,
          premiumPrice: article.premiumPrice,
          categoryId: article.categoryId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  int _getCategoriesCount() {
    try {
      if (!Get.isRegistered<CategoryController>()) return 0;
      final categoryController = Get.find<CategoryController>();
      return categoryController.categories.length;
    } catch (e) {
      print('[ArticlesScreenSafe] Error getting categories count: $e');
      return 0;
    }
  }

  double _getAveragePrice() {
    try {
      if (controller?.articles.isEmpty ?? true) return 0.0;
      final total = controller!.articles.fold<double>(
        0.0,
        (sum, article) => sum + article.basePrice,
      );
      return total / controller!.articles.length;
    } catch (e) {
      print('[ArticlesScreenSafe] Error calculating average price: $e');
      return 0.0;
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }
}
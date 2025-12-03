/**
 * 📝 Blog Management Screen - Écran de gestion des articles de blog
 */

import 'package:admin/constants.dart';
import 'package:admin/controllers/blog_article_controller.dart';
import 'package:admin/models/blog_article.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlogManagementScreen extends StatefulWidget {
  const BlogManagementScreen({Key? key}) : super(key: key);

  @override
  State<BlogManagementScreen> createState() => _BlogManagementScreenState();
}

class _BlogManagementScreenState extends State<BlogManagementScreen>
    with SingleTickerProviderStateMixin {
  late BlogArticleController controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (Get.isRegistered<BlogArticleController>()) {
      controller = Get.find<BlogArticleController>();
    } else {
      controller = Get.put(BlogArticleController(), permanent: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Flexible(
                flex: 0,
                child: _buildHeader(context, isDark),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre de la section
                      Text(
                        'Gestion des Articles de Blog',
                        style: AppTextStyles.h2.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Créez, publiez et gérez vos articles de blog',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Statistiques
                      _buildStatsSection(controller, isDark),
                      SizedBox(height: AppSpacing.lg),

                      // Onglets
                      _buildTabsSection(controller, isDark),
                      SizedBox(height: AppSpacing.md),

                      // Contenu
                      _buildContentSection(controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              'Articles de Blog',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Obx(() => Text(
                  controller.isLoading.value
                      ? 'Chargement...'
                      : '${controller.totalArticles} article${controller.totalArticles > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: () => controller.loadArticles(),
            ),
            SizedBox(width: AppSpacing.sm),
            Obx(
              () => GlassButton(
                label: 'Générer',
                icon: Icons.auto_awesome,
                variant: GlassButtonVariant.primary,
                size: GlassButtonSize.small,
                isLoading: controller.isGenerating.value,
                onPressed: controller.isGenerating.value
                    ? null
                    : () => _showGenerateDialog(context, controller),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BlogArticleController controller, bool isDark) {
    return Obx(
      () => GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            context,
            isDark,
            title: 'Total',
            value: controller.totalArticles.toString(),
            icon: Icons.article,
            color: AppColors.primary,
            trend: '+${controller.totalArticles}',
          ),
          _buildStatCard(
            context,
            isDark,
            title: 'Publiés',
            value: controller.publishedCount.toString(),
            icon: Icons.check_circle,
            color: AppColors.success,
            trend: controller.publishedCount > 0 ? '✓' : '0',
          ),
          _buildStatCard(
            context,
            isDark,
            title: 'En attente',
            value: controller.pendingCount.toString(),
            icon: Icons.schedule,
            color: AppColors.warning,
            trend: controller.pendingCount > 0 ? 'Action' : 'Aucun',
          ),
          _buildStatCard(
            context,
            isDark,
            title: 'Taux',
            value: '${controller.generationRate}%',
            icon: Icons.trending_up,
            color: AppColors.accent,
            trend: controller.generationRate,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return GlassContainer(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    trend,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection(BlogArticleController controller, bool isDark) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.gray400 : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.article),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Articles (${controller.articles.length})'),
                  ],
                ),
              ),
            ),
            Tab(
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: AppSpacing.sm),
                    Text('En attente (${controller.pendingArticles.length})'),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildArticlesTab(controller, isDark),
              _buildPendingTab(controller, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesTab(BlogArticleController controller, bool isDark) {
    return Obx(
      () => controller.articles.isEmpty
          ? Center(
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
                    'Créez ou générez des articles pour commencer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: controller.articles.length,
              itemBuilder: (context, index) {
                final article = controller.articles[index];
                return _buildArticleCard(article, controller, isDark);
              },
            ),
    );
  }

  Widget _buildPendingTab(BlogArticleController controller, bool isDark) {
    return Obx(
      () => controller.pendingArticles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: AppRadius.radiusXL,
                    ),
                    child: Icon(
                      Icons.schedule_outlined,
                      size: 60,
                      color: AppColors.warning.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Aucun article en attente',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tous les articles générés ont été publiés',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: controller.pendingArticles.length,
              itemBuilder: (context, index) {
                final article = controller.pendingArticles[index];
                return _buildPendingArticleCard(article, controller, isDark);
              },
            ),
    );
  }

  Widget _buildArticleCard(BlogArticle article, BlogArticleController controller, bool isDark) {
    return GlassContainer(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: article.featuredImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.network(
                  article.featuredImage!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.article),
              ),
        title: Text(
          article.title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.xs),
            Text(
              article.excerpt,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    '${article.readingTime} min',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    '👁️ ${article.viewsCount}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Éditer'),
              onTap: () => _showEditDialog(context, article, controller),
            ),
            PopupMenuItem(
              child: const Text('Supprimer'),
              onTap: () => _showDeleteDialog(context, article, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingArticleCard(BlogArticle article, BlogArticleController controller, bool isDark) {
    return GlassContainer(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      variant: GlassContainerVariant.warning,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: AppRadius.radiusSM,
          ),
          child: Icon(
            Icons.schedule,
            color: AppColors.warning,
            size: 24,
          ),
        ),
        title: Text(
          article.title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          article.excerpt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.textSecondary,
          ),
        ),
        trailing: GlassButton(
          label: 'Publier',
          icon: Icons.publish,
          variant: GlassButtonVariant.success,
          size: GlassButtonSize.small,
          onPressed: () => controller.publishArticle(article.id),
        ),
      ),
    );
  }

  Widget _buildContentSection(BlogArticleController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recherche et Filtrage',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          onChanged: (value) => controller.search(value),
          decoration: InputDecoration(
            hintText: 'Rechercher un article...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ],
    );
  }

  void _showGenerateDialog(BuildContext context, BlogArticleController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Générer un Article'),
        content: const Text(
          'Un nouvel article sera généré basé sur les tendances actuelles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.generateArticle();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('Générer'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    BlogArticle article,
    BlogArticleController controller,
  ) {
    final titleController = TextEditingController(text: article.title);
    final contentController = TextEditingController(text: article.content);
    final excerptController = TextEditingController(text: article.excerpt);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Éditer l\'Article',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        'Titre',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: titleController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Titre de l\'article',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Contenu
                      Text(
                        'Contenu Complet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: contentController,
                        maxLines: 12,
                        decoration: InputDecoration(
                          hintText: 'Contenu complet de l\'article',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Extrait
                      Text(
                        'Extrait (Résumé)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: excerptController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Résumé de l\'article (max 500 caractères)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Annuler',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: AppSpacing.md),
                  GlassButton(
                    label: 'Enregistrer',
                    variant: GlassButtonVariant.primary,
                    onPressed: () {
                      controller.updateArticle(
                        article.id,
                        {
                          'title': titleController.text,
                          'content': contentController.text,
                          'excerpt': excerptController.text,
                        },
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    BlogArticle article,
    BlogArticleController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'Article'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteArticle(article.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

import 'package:admin/models/article.dart';
import 'package:admin/screens/articles/components/article_card.dart';
import 'package:admin/screens/articles/components/article_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/article_controller.dart';
import '../../responsive.dart';
import './components/article_list_item.dart';
import 'package:admin/widgets/shared/bouncy_button.dart'; // Ajouter cet import
import 'package:admin/widgets/shared/glass_button.dart';

class ArticlesScreen extends GetView<ArticleController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: defaultPadding),
              _buildSearchAndViewToggle(context),
              SizedBox(height: defaultPadding),
              Expanded(
                child: Obx(() => _buildArticlesList(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Gestion des Articles',
          style: AppTextStyles.h1.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Row(
          children: [
            GlassButton(
              label: 'Nouvel Article',
              icon: Icons.add,
              variant: GlassButtonVariant.primary,
              onPressed: () => _showAddArticleDialog(context),
            ),
            const SizedBox(width: 8),
            GlassButton(
              icon: Icons.refresh,
              label: '',
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: controller.fetchArticles,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndViewToggle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.searchArticles,
            decoration: InputDecoration(
              hintText: "Rechercher un article...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            children: [
              _buildViewModeButton(
                icon: Icons.grid_view,
                mode: ArticleViewMode.grid,
              ),
              _buildViewModeButton(
                icon: Icons.list,
                mode: ArticleViewMode.list,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required ArticleViewMode mode,
  }) {
    return Obx(() {
      final isSelected = controller.viewMode.value == mode;
      return InkWell(
        onTap: () => controller.toggleViewMode(mode),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            borderRadius: AppRadius.radiusSM,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      );
    });
  }

  Widget _buildArticlesList(BuildContext context) {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.articles.isEmpty) {
      return Center(
        child: Text('Aucun article trouvé'),
      );
    }

    return Obx(() {
      if (controller.viewMode.value == ArticleViewMode.grid) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            crossAxisSpacing: defaultPadding,
            mainAxisSpacing: defaultPadding,
            childAspectRatio: 1.3,
          ),
          itemCount: controller.articles.length,
          itemBuilder: (context, index) {
            final article = controller.articles[index];
            return ArticleCard(
              article: article, // Only pass the article
            );
          },
        );
      } else {
        return ListView.builder(
          itemCount: controller.articles.length,
          itemBuilder: (context, index) {
            final article = controller.articles[index];
            return ArticleListItem(
              article: article,
              onEdit: () => Get.dialog(
                ArticleFormDialog(article: article),
                barrierDismissible: false,
              ),
              onDelete: () => controller.deleteArticle(article.id),
            );
          },
        );
      }
    });
  }

  void _showAddArticleDialog(BuildContext context) {
    Get.dialog(
      ArticleFormDialog(),
      barrierDismissible: false,
    );
  }

  void _showEditArticleDialog(Article article) {
    print('[ArticlesScreen] Opening edit dialog for article: ${article.id}');
    Get.dialog(
      ArticleFormDialog(article: article),
      barrierDismissible: false,
    );
  }

  void _showDeleteConfirmation(BuildContext context, Article article) {
    // TODO: Implement delete confirmation
  }

  int _getCrossAxisCount(BuildContext context) {
    if (Responsive.isDesktop(context)) return 3;
    if (Responsive.isTablet(context)) return 2;
    return 1;
  }
}

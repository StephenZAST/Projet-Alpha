/**
 * 📝 Blog Article Controller - Contrôleur pour la gestion des articles de blog
 */

import 'package:admin/models/blog_article.dart';
import 'package:admin/services/blog_article_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlogArticleController extends GetxController {
  late final BlogArticleService _blogService;

  // Observables
  final articles = <BlogArticle>[].obs;
  final pendingArticles = <BlogArticle>[].obs;
  final trends = <String>[].obs;
  final isLoading = false.obs;
  final isGenerating = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final selectedCategory = Rx<String?>(null);
  final searchQuery = ''.obs;
  final stats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialiser le service depuis GetX
    _blogService = Get.find<BlogArticleService>();
    print('[BlogArticleController] Service initialized');
    loadArticles();
    loadPendingArticles();
    loadStats();
  }

  // Charger tous les articles
  Future<void> loadArticles({int page = 1}) async {
    try {
      isLoading.value = true;
      final response = await _blogService.getAllArticles(
        page: page,
        category: selectedCategory.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      articles.value = response.data;
      currentPage.value = response.page;
      totalPages.value = response.totalPages;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les articles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les articles en attente
  Future<void> loadPendingArticles() async {
    try {
      isLoading.value = true;
      pendingArticles.value = await _blogService.getPendingArticles();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les articles en attente: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les tendances
  Future<void> loadTrends() async {
    try {
      trends.value = await _blogService.getTrends();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les tendances: $e');
    }
  }

  // Charger les statistiques
  Future<void> loadStats() async {
    try {
      stats.value = await _blogService.getStats();
    } catch (e) {
      print('❌ Error loading stats: $e');
    }
  }

  // Générer un seul article (asynchrone avec queue)
  Future<void> generateArticle() async {
    try {
      isGenerating.value = true;
      print('[BlogArticleController] Début de la génération d\'un article (asynchrone)');
      
      final result = await _blogService.generateArticle();

      print('[BlogArticleController] Réponse: $result');
      
      final jobId = result['jobId'] as String? ?? '';
      final topic = result['topic'] as String? ?? '';
      final message = result['message'] as String? ?? 'Article en cours de génération';
      
      Get.snackbar(
        'Succès',
        '$message\nSujet: $topic',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );

      print('[BlogArticleController] Job créé: $jobId');
      
      // Attendre un peu avant de recharger les données
      await Future.delayed(Duration(seconds: 2));
      
      // Recharger les statistiques et articles
      await loadStats();
      await loadArticles();
      
      print('[BlogArticleController] Données rechargées');
    } catch (e) {
      print('[BlogArticleController] Erreur lors de la génération: $e');
      Get.snackbar(
        'Erreur de Génération',
        'Impossible de générer l\'article: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Publier un article
  Future<void> publishArticle(String id) async {
    try {
      isLoading.value = true;
      await _blogService.publishArticle(id);

      Get.snackbar('Succès', 'Article publié avec succès');

      await loadPendingArticles();
      await loadArticles();
      await loadStats();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de publier l\'article: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le statut de publication d'un article
  Future<void> updatePublicationStatus(String id, bool isPublished) async {
    try {
      isLoading.value = true;
      await _blogService.updatePublicationStatus(id, isPublished);

      final action = isPublished ? 'publié' : 'dépublié';
      Get.snackbar('Succès', 'Article $action avec succès');

      await loadPendingArticles();
      await loadArticles();
      await loadStats();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour l\'article: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un article
  Future<void> deleteArticle(String id) async {
    try {
      isLoading.value = true;
      await _blogService.deleteArticle(id);

      Get.snackbar('Succès', 'Article supprimé avec succès');

      await loadArticles();
      await loadStats();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer l\'article: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour un article
  Future<void> updateArticle(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _blogService.updateArticle(id, data);

      Get.snackbar('Succès', 'Article mis à jour avec succès');

      await loadArticles();
      await loadStats();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour l\'article: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer par catégorie
  void filterByCategory(String? category) {
    selectedCategory.value = category;
    currentPage.value = 1;
    loadArticles();
  }

  // Rechercher
  void search(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadArticles();
  }

  // Aller à la page suivante
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadArticles(page: currentPage.value);
    }
  }

  // Aller à la page précédente
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadArticles(page: currentPage.value);
    }
  }

  // Obtenir le nombre total d'articles
  int get totalArticles => stats['total'] ?? 0;

  // Obtenir le nombre d'articles publiés
  int get publishedCount => stats['published'] ?? 0;

  // Obtenir le nombre d'articles en attente
  int get pendingCount => stats['pending'] ?? 0;

  // Obtenir le taux de génération (toujours une String)
  String get generationRate {
    final rate = stats['generationRate'];
    if (rate == null) return '0';
    if (rate is String) return rate;
    if (rate is int) return rate.toString();
    if (rate is double) return rate.toStringAsFixed(2);
    return '0';
  }
}

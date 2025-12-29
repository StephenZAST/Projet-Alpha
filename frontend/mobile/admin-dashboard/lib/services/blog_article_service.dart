/**
 * 📝 Blog Article Service - Service pour gérer les articles de blog
 */

import 'package:admin/models/blog_article.dart';
import 'package:admin/services/api_service.dart';
import 'package:get/get.dart';

class BlogArticleService extends GetxService {
  late final ApiService _apiService;

  static const String _baseUrl = '/api/blog-articles';
  static const String _generatorUrl = '/api/blog-generator';

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    print('[BlogArticleService] Initialized with ApiService');
  }

  // Récupérer tous les articles
  Future<BlogArticleResponse> getAllArticles({
    int page = 1,
    int limit = 12,
    String? category,
    String? search,
    String sort = 'latest',
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        'sort': sort,
      };

      final response = await _apiService.get(
        _baseUrl,
        queryParameters: params,
      );

      return BlogArticleResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error fetching articles: $e');
      rethrow;
    }
  }

  // Récupérer un article par slug
  Future<BlogArticle> getArticleBySlug(String slug) async {
    try {
      final response = await _apiService.get('$_baseUrl/slug/$slug');
      return BlogArticle.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error fetching article by slug: $e');
      rethrow;
    }
  }

  // Créer un article
  Future<BlogArticle> createArticle(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(_baseUrl, data: data);
      return BlogArticle.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error creating article: $e');
      rethrow;
    }
  }

  // Mettre à jour un article
  Future<BlogArticle> updateArticle(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('$_baseUrl/$id', data: data);
      return BlogArticle.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error updating article: $e');
      rethrow;
    }
  }

  // Supprimer un article
  Future<void> deleteArticle(String id) async {
    try {
      await _apiService.delete('$_baseUrl/$id');
    } catch (e) {
      print('❌ Error deleting article: $e');
      rethrow;
    }
  }

  // Générer un seul article (asynchrone avec queue)
  Future<Map<String, dynamic>> generateArticle() async {
    try {
      print('[BlogArticleService] Génération d\'un article (asynchrone)...');
      
      final response = await _apiService.post(
        '/api/blog-queue/generate',
        data: {},
      );

      print('✅ Article ajouté à la queue');
      print('[BlogArticleService] Response: ${response.data}');
      
      return {
        'success': response.data['success'] ?? true,
        'message': response.data['message'] ?? 'Article en cours de génération',
        'jobId': response.data['jobId'] ?? '',
        'topic': response.data['topic'] ?? '',
        'status': response.data['status'] ?? 'pending',
      };
    } catch (e) {
      print('❌ Error generating article: $e');
      rethrow;
    }
  }

  // Obtenir le statut d'un job de génération
  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    try {
      final response = await _apiService.get('/api/blog-queue/jobs/$jobId');
      return response.data['job'] ?? {};
    } catch (e) {
      print('❌ Error fetching job status: $e');
      rethrow;
    }
  }

  // Obtenir les statistiques de la queue
  Future<Map<String, dynamic>> getQueueStats() async {
    try {
      final response = await _apiService.get('/api/blog-queue/stats');
      return response.data['stats'] ?? {};
    } catch (e) {
      print('❌ Error fetching queue stats: $e');
      rethrow;
    }
  }

  // Obtenir tous les jobs
  Future<List<Map<String, dynamic>>> getAllJobs() async {
    try {
      final response = await _apiService.get('/api/blog-queue/jobs');
      final jobs = (response.data['jobs'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      return jobs;
    } catch (e) {
      print('❌ Error fetching all jobs: $e');
      rethrow;
    }
  }

  // Récupérer les articles en attente
  Future<List<BlogArticle>> getPendingArticles() async {
    try {
      final response = await _apiService.get('$_generatorUrl/pending');
      final articles = (response.data['data'] as List?)
              ?.map((e) => BlogArticle.fromJson(e))
              .toList() ??
          [];

      print('📋 Found ${articles.length} pending articles');
      return articles;
    } catch (e) {
      print('❌ Error fetching pending articles: $e');
      rethrow;
    }
  }

  // Publier un article
  Future<BlogArticle> publishArticle(String id) async {
    try {
      final response =
          await _apiService.post('$_generatorUrl/$id/publish', data: {});
      return BlogArticle.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error publishing article: $e');
      rethrow;
    }
  }

  // Mettre à jour le statut de publication d'un article
  Future<BlogArticle> updatePublicationStatus(String id, bool isPublished) async {
    try {
      final response = await _apiService.put(
        '$_generatorUrl/$id/status',
        data: {'isPublished': isPublished},
      );
      return BlogArticle.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error updating publication status: $e');
      rethrow;
    }
  }

  // Récupérer les tendances
  Future<List<String>> getTrends({String geo = 'BF'}) async {
    try {
      final response = await _apiService.get(
        '$_generatorUrl/trends',
        queryParameters: {'geo': geo},
      );

      final trends = List<String>.from(response.data['data'] ?? []);
      print('🔍 Found ${trends.length} trends');
      return trends;
    } catch (e) {
      print('❌ Error fetching trends: $e');
      rethrow;
    }
  }

  // Récupérer les statistiques
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get('$_generatorUrl/stats');
      return response.data['data'] ?? {};
    } catch (e) {
      print('❌ Error fetching stats: $e');
      rethrow;
    }
  }

  // Incrémenter les vues
  Future<void> incrementViews(String id) async {
    try {
      await _apiService.post('$_baseUrl/$id/views', data: {});
    } catch (e) {
      print('❌ Error incrementing views: $e');
      // Ne pas relancer l'erreur pour les vues
    }
  }
}

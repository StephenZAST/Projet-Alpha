import '../models/article_service.dart';
import './api_service.dart';

class ArticleServiceService {
  static final _api = ApiService();
  static const _baseUrl = 'api/article-services';

  static Future<List<ArticleService>> getAllArticleServices() async {
    try {
      final response = await _api.get(_baseUrl);
      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => ArticleService.fromJson(json))
            .toList();
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      return [];
    } catch (e) {
      print('[ArticleServiceService] Error getting all article services: $e');
      throw 'Erreur lors du chargement des services associés';
    }
  }

  static Future<ArticleService> createArticleService(
      ArticleServiceCreateDTO dto) async {
    try {
      final response = await _api.post(
        _baseUrl,
        data: dto.toJson(),
      );
      if (response.data != null && response.data['data'] != null) {
        return ArticleService.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw 'Erreur lors de la création du service associé';
    } catch (e) {
      print('[ArticleServiceService] Error creating article service: $e');
      throw 'Erreur lors de la création du service associé';
    }
  }

  static Future<ArticleService> updateArticleService({
    required String id,
    required ArticleServiceUpdateDTO dto,
  }) async {
    try {
      final response = await _api.put(
        // Backend utilise PUT
        '$_baseUrl/$id',
        data: dto.toJson(),
      );
      if (response.data != null && response.data['data'] != null) {
        return ArticleService.fromJson(response.data['data']);
      }
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
      throw 'Erreur lors de la mise à jour du service associé';
    } catch (e) {
      print('[ArticleServiceService] Error updating article service: $e');
      if (e.toString().contains('404')) {
        throw 'Service associé non trouvé';
      }
      throw 'Erreur lors de la mise à jour du service associé';
    }
  }

  static Future<void> deleteArticleService(String id) async {
    try {
      final response = await _api.delete('$_baseUrl/$id');
      if (response.data?['error'] != null) {
        throw response.data['error'];
      }
    } catch (e) {
      print('[ArticleServiceService] Error deleting article service: $e');
      if (e.toString().contains('404')) {
        throw 'Service associé non trouvé';
      }
      throw 'Erreur lors de la suppression du service associé';
    }
  }

  static Future<List<ArticleService>> getArticleServicesByArticleId(
      String articleId) async {
    try {
      // Étant donné qu'il n'y a pas d'endpoint spécifique, nous filtrons côté client
      final services = await getAllArticleServices();
      return services
          .where((service) => service.articleId == articleId)
          .toList();
    } catch (e) {
      print(
          '[ArticleServiceService] Error getting article services by article id: $e');
      throw 'Erreur lors du chargement des services associés';
    }
  }

  static Future<List<ArticleService>> getArticleServicesByServiceId(
      String serviceId) async {
    try {
      // Étant donné qu'il n'y a pas d'endpoint spécifique, nous filtrons côté client
      final services = await getAllArticleServices();
      return services
          .where((service) => service.serviceId == serviceId)
          .toList();
    } catch (e) {
      print(
          '[ArticleServiceService] Error getting article services by service id: $e');
      throw 'Erreur lors du chargement des articles associés';
    }
  }
}

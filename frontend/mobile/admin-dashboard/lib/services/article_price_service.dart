import '../services/api_service.dart';

class ArticlePriceService {
  static const String _baseUrl = '/api/article-services';
  static final ApiService _api = ApiService();

  /// Récupère les prix du couple article/service
  static Future<Map<String, dynamic>?> getArticleServicePrice({
    required String articleId,
    required String serviceTypeId,
  }) async {
    try {
      final url = '$_baseUrl/$articleId/prices';
      final response = await _api.get(url, queryParameters: {
        'serviceTypeId': serviceTypeId,
      });
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('[ArticlePriceService] Error fetching price: $e');
      return null;
    }
  }
}

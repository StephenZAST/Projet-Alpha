import '../services/api_service.dart';
import '../models/service_type.dart';

class ServiceTypeService {
  static const String _baseUrl = '/api/service-types';
  static final ApiService _apiService = ApiService();

  static Future<List<ServiceType>> getAllServiceTypes() async {
    try {
      final response = await _apiService.get(_baseUrl);
      if (response.data != null && response.data['data'] != null) {
        final List<ServiceType> types = (response.data['data'] as List)
            .map((item) => ServiceType.fromJson(item))
            .toList();
        return types;
      }
      return [];
    } catch (e) {
      print('Error fetching service types: $e');
      rethrow;
    }
  }
}

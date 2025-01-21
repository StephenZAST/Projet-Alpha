import 'api_service.dart';
import '../models/service.dart';

class ServiceService {
  static Future<List<Service>> getServices() async {
    final response = await ApiService.get('services');
    return (response['data'] as List)
        .map((json) => Service.fromJson(json))
        .toList();
  }

  static Future<Service> createService(Map<String, dynamic> data) async {
    final response = await ApiService.post('services', data);
    return Service.fromJson(response['data']);
  }

  static Future<Service> updateService(
      String id, Map<String, dynamic> data) async {
    final response = await ApiService.put('services/$id', data);
    return Service.fromJson(response['data']);
  }

  static Future<void> deleteService(String id) async {
    await ApiService.delete('services/$id');
  }
}

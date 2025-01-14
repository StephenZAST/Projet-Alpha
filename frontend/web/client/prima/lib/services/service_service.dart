import 'package:dio/dio.dart';
import '../models/service.dart';

class ServiceService {
  final Dio _dio;

  ServiceService(this._dio);

  Future<List<Service>> getAllServices() async {
    try {
      final response = await _dio.get('/api/services/all');
      if (response.data['success'] == true) {
        final List<dynamic> servicesData = response.data['data'] ?? [];
        return servicesData.map((json) => Service.fromJson(json)).toList();
      }
      throw response.data['message'] ?? 'Failed to load services';
    } catch (e) {
      throw 'Error loading services: $e';
    }
  }
}

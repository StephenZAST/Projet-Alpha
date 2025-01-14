import 'package:dio/dio.dart';
import '../models/service.dart';

class ServiceService {
  final Dio dio;

  ServiceService(this.dio);

  Future<List<Service>> getServices() async {
    try {
      final response = await dio.get('/api/services/all');
      print('Service response data: ${response.data}');
      return (response.data as List)
          .map((json) => Service.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }
}

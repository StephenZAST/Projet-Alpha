import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/service.dart';

class ServiceProvider with ChangeNotifier {
  final Dio _dio;
  List<Service> _services = [];
  bool _loading = false;
  String? _error;

  ServiceProvider(this._dio);

  List<Service> get services => _services;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadServices() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _dio.get('/api/services/all');

      if (response.data['success'] == true) {
        final List<dynamic> servicesData = response.data['data'] ?? [];
        _services = servicesData.map((json) => Service.fromJson(json)).toList();
      } else {
        throw response.data['message'] ?? 'Failed to load services';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

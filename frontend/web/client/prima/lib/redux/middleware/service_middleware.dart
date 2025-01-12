import 'dart:developer';

import 'package:redux/redux.dart';
import 'package:dio/dio.dart';
import '../store.dart';
import '../actions/service_actions.dart';
import '../../models/service.dart';

class ServiceMiddleware {
  final Dio dio;

  ServiceMiddleware(this.dio);

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoadServicesAction>(_handleLoadServices),
    ];
  }

  void _handleLoadServices(
    Store<AppState> store,
    LoadServicesAction action,
    NextDispatcher next,
  ) async {
    print('ServiceMiddleware: Loading services...'); // Log pour debug
    next(action);

    try {
      final response = await dio.get('/api/services/all');
      print('Service API Response: ${response.data}'); // Log pour debug

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        try {
          final services = data.map((json) => Service.fromJson(json)).toList();
          print('Parsed ${services.length} services'); // Log pour debug
          store.dispatch(LoadServicesSuccessAction(services));
        } catch (parseError) {
          print('Error parsing services: $parseError'); // Log pour debug
          store.dispatch(LoadServicesFailureAction(
              'Error parsing service data: $parseError'));
        }
      } else {
        print('Service API Error: ${response.statusCode}'); // Log pour debug
        store.dispatch(LoadServicesFailureAction(
            response.data['error'] ?? 'Failed to load services'));
      }
    } catch (e) {
      print('Service Network Error: $e'); // Log pour debug
      store.dispatch(LoadServicesFailureAction('Network error: $e'));
    }
  }
}

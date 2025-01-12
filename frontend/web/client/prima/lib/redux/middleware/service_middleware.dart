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
    next(action);

    try {
      final response = await dio.get('/api/services/all');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<ServiceModel>? services =
            data.map((json) => ServiceModel.fromJson(json)).toList();
        store.dispatch(LoadServicesSuccessAction(services));
      } else {
        store.dispatch(LoadServicesFailureAction(
          response.data['error'] ?? 'Failed to load services',
        ));
      }
    } catch (e) {
      store.dispatch(LoadServicesFailureAction(e.toString()));
    }
  }
}

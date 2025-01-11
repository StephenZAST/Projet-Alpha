import 'package:redux/redux.dart';
import 'package:dio/dio.dart';
import '../store.dart';
import '../actions/service_actions.dart';
import '../../widgets/order_bottom_sheet.dart';

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
        final services = data.map((json) => Service.fromJson(json)).toList();
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

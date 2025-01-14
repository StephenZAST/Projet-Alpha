import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import 'package:dio/dio.dart';
import '../actions/service_actions.dart';
import '../../services/service_service.dart';

class ServiceMiddleware {
  final Dio dio;
  late final ServiceService serviceService;

  ServiceMiddleware(this.dio) {
    serviceService = ServiceService(dio);
  }

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
      print('Fetching services from /api/services/all...');
      final services = await serviceService.getServices();
      print('Services fetched successfully: ${services.length}');
      store.dispatch(LoadServicesSuccessAction(services));
    } catch (error) {
      print('Error loading services: ${error.toString()}');
      if (error is DioException) {
        print('DioError details: ${error.response?.data}');
      }
      store.dispatch(LoadServicesFailureAction(error.toString()));
    }
  }
}

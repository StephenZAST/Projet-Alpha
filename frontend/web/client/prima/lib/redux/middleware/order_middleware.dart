import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import 'package:dio/dio.dart';
import '../actions/order_actions.dart';
import '../../models/order.dart';

class OrderMiddleware {
  final Dio dio;

  OrderMiddleware(this.dio);

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, CreateOrderAction>(_handleCreateOrder),
      TypedMiddleware<AppState, LoadOrdersAction>(_handleLoadOrders),
    ];
  }

  void _handleCreateOrder(
    Store<AppState> store,
    CreateOrderAction action,
    NextDispatcher next,
  ) async {
    next(action);
    print('OrderMiddleware: Creating order...'); // Debug log

    try {
      final response = await dio.post(
        '/api/orders',
        data: {
          'address_id': action.addressId,
          'service_id': store.state.orderState.selectedService?.id,
          'articles': store.state.orderState.selectedArticles,
          'collection_date':
              store.state.orderState.collectionDate?.toIso8601String(),
          'delivery_date':
              store.state.orderState.deliveryDate?.toIso8601String(),
        },
      );

      if (response.statusCode == 201) {
        print('Order created successfully'); // Debug log
        store.dispatch(CreateOrderSuccessAction());
      } else {
        print('Order creation failed: ${response.data}'); // Debug log
        store.dispatch(CreateOrderFailureAction(
          response.data['error'] ?? 'Failed to create order',
        ));
      }
    } catch (e) {
      print('Order creation error: $e'); // Debug log
      store.dispatch(CreateOrderFailureAction(e.toString()));
    }
  }

  void _handleLoadOrders(
    Store<AppState> store,
    LoadOrdersAction action,
    NextDispatcher next,
  ) async {
    next(action);
    print('OrderMiddleware: Loading orders...'); // Debug log

    try {
      final response = await dio.get('/api/orders');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final orders = data.map((json) => Order.fromJson(json)).toList();
        print('Loaded ${orders.length} orders'); // Debug log
        store.dispatch(LoadOrdersSuccessAction(orders));
      } else {
        print('Order loading failed: ${response.data}'); // Debug log
        store.dispatch(LoadOrdersFailureAction(
          response.data['error'] ?? 'Failed to load orders',
        ));
      }
    } catch (e) {
      print('Order loading error: $e'); // Debug log
      store.dispatch(LoadOrdersFailureAction(e.toString()));
    }
  }
}

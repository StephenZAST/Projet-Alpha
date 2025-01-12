import 'package:prima/widgets/order_bottom_sheet.dart';

import '../states/order_state.dart';
import '../actions/order_actions.dart';
import '../../models/service.dart';
import '../../models/article.dart';

OrderState orderReducer(OrderState state, dynamic action) {
  print(
      'OrderReducer: handling action ${action.runtimeType}'); // Log pour debug

  if (action is UpdateOrderServiceAction) {
    print('Updating service: ${action.service}'); // Log pour debug
    return state.copyWith(
      selectedService: action.service, // Plus besoin du cast
    );
  }

  if (action is UpdateOrderArticleQuantityAction) {
    final newSelectedArticles = Map<String, int>.from(state.selectedArticles);
    if (action.quantity <= 0) {
      newSelectedArticles.remove(action.articleId);
    } else {
      newSelectedArticles[action.articleId] = action.quantity;
    }
    return state.copyWith(selectedArticles: newSelectedArticles);
  }

  if (action is SetOrderDatesAction) {
    return state.copyWith(
      collectionDate: action.collectionDate,
      deliveryDate: action.deliveryDate,
    );
  }

  if (action is CreateOrderAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is CreateOrderSuccessAction) {
    return OrderState(); // Reset state after successful order
  }

  if (action is CreateOrderFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is ResetOrderAction) {
    return OrderState();
  }

  return state;
}

import '../states/order_state.dart';
import '../actions/order_actions.dart';
import '../../models/service.dart';
import '../../models/article.dart';

OrderState orderReducer(OrderState state, dynamic action) {
  if (action is UpdateOrderServiceAction) {
    return state.copyWith(
      selectedService: action.service,
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

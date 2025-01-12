import '../../models/service.dart'; // Assurez-vous que ce fichier existe
import '../../models/article.dart'; // Ajouter cet import
import '../../models/order.dart'; // Assurez-vous d'avoir ce modèle

class UpdateOrderServiceAction {
  final Service? service; // Changé de ServiceModel à Service
  UpdateOrderServiceAction(this.service);
}

class UpdateOrderArticleQuantityAction {
  final String articleId;
  final int quantity;
  UpdateOrderArticleQuantityAction(this.articleId, this.quantity);
}

class SetOrderDatesAction {
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  SetOrderDatesAction({this.collectionDate, this.deliveryDate});
}

class CreateOrderAction {
  final String addressId;
  CreateOrderAction(this.addressId);
}

class CreateOrderSuccessAction {}

class CreateOrderFailureAction {
  final String error;
  CreateOrderFailureAction(this.error);
}

class ResetOrderAction {}

// Nouvelles actions pour le chargement des commandes
class LoadOrdersAction {}

class LoadOrdersSuccessAction {
  final List<Order> orders;
  LoadOrdersSuccessAction(this.orders);
}

class LoadOrdersFailureAction {
  final String error;
  LoadOrdersFailureAction(this.error);
}

import '../../models/service.dart'; // Assurez-vous que ce fichier existe
import '../../models/article.dart'; // Ajouter cet import

class UpdateOrderServiceAction {
  final ServiceModel? service; // Changé de Service à ServiceModel
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

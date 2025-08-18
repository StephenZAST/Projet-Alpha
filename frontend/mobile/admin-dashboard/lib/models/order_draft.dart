class OrderDraft {
  String? clientId;
  String? addressId;
  String? serviceId;
  String? serviceTypeId;
  List<OrderDraftItem> items = [];
  // Champs additionnels pour la commande
  DateTime? collectionDate;
  DateTime? deliveryDate;
  String? status;
  String? paymentMethod;
  String? affiliateCode;
  String? recurrenceType;
  DateTime? nextRecurrenceDate;

  Map<String, dynamic> toPayload() {
    return {
      'userId': clientId,
      'addressId': addressId,
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'items': items.map((e) => e.toPayload()).toList(),
      'collectionDate': collectionDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'affiliateCode': affiliateCode,
      'recurrenceType': recurrenceType,
      'nextRecurrenceDate': nextRecurrenceDate?.toIso8601String(),
    };
  }

  // Setter générique pour champs additionnels
  void setField(String key, dynamic value) {
    switch (key) {
      case 'collectionDate':
        collectionDate = value;
        break;
      case 'deliveryDate':
        deliveryDate = value;
        break;
      case 'status':
        status = value;
        break;
      case 'paymentMethod':
        paymentMethod = value;
        break;
      case 'affiliateCode':
        affiliateCode = value;
        break;
      case 'recurrenceType':
        recurrenceType = value;
        break;
      case 'nextRecurrenceDate':
        nextRecurrenceDate = value;
        break;
      default:
        break;
    }
  }
}

class OrderDraftItem {
  String articleId;
  int quantity;
  bool isPremium;

  OrderDraftItem({
    required this.articleId,
    required this.quantity,
    this.isPremium = false,
  });

  Map<String, dynamic> toPayload() {
    return {
      'articleId': articleId,
      'quantity': quantity,
      'isPremium': isPremium,
    };
  }
}

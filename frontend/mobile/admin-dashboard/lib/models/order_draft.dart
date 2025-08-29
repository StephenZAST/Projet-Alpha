class OrderDraft {
  String? clientId;
  String? addressId;
  String? serviceId;
  String? serviceTypeId;
  List<OrderDraftItem> items = [];
  // Champs additionnels pour la commande
  String? note;
  DateTime? collectionDate;
  DateTime? deliveryDate;
  String? status;
  String? paymentMethod;
  String? affiliateCode;
  String? recurrenceType;
  DateTime? nextRecurrenceDate;

  Map<String, dynamic> toPayload() {
    print(
        '[OrderDraft] toPayload: serviceTypeId=$serviceTypeId, serviceId=$serviceId, clientId=$clientId');
    return {
      'userId': clientId,
      'addressId': addressId,
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'items':
          items.map((e) => e.toPayload(serviceTypeId: serviceTypeId)).toList(),
      'collectionDate': collectionDate != null
          ? collectionDate!.toUtc().toIso8601String()
          : null,
      'deliveryDate':
          deliveryDate != null ? deliveryDate!.toUtc().toIso8601String() : null,
      'paymentMethod': paymentMethod,
      'affiliateCode': affiliateCode,
      'recurrenceType': recurrenceType,
      'nextRecurrenceDate': nextRecurrenceDate != null
          ? nextRecurrenceDate!.toUtc().toIso8601String()
          : null,
      'note': note,
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
      case 'note':
        note = value;
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
  String? serviceId;

  OrderDraftItem({
    required this.articleId,
    required this.quantity,
    this.isPremium = false,
    this.serviceId,
  });

  Map<String, dynamic> toPayload({String? serviceTypeId}) {
    return {
      'articleId': articleId,
      'quantity': quantity,
      'isPremium': isPremium,
      if (serviceTypeId != null) 'serviceTypeId': serviceTypeId,
      if (serviceId != null) 'serviceId': serviceId,
    };
  }
}

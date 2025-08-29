class FlashOrderDraft {
  String? orderId;
  String? userId;
  String? addressId;
  String? serviceId;
  String? serviceTypeId;
  List<FlashOrderDraftItem> items = [];
  DateTime? collectionDate;
  DateTime? deliveryDate;
  String? note;

  FlashOrderDraft({
    this.orderId,
    this.userId,
    this.addressId,
    this.serviceId,
    this.serviceTypeId,
    List<FlashOrderDraftItem>? items,
    this.collectionDate,
    this.deliveryDate,
    this.note,
  }) {
    if (items != null) this.items = items;
  }

  Map<String, dynamic> toPayload() {
    return {
      'orderId': orderId,
      'userId': userId,
      'addressId': addressId,
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'items': items.map((e) => e.toPayload()).toList(),
      'collectionDate': collectionDate?.toUtc().toIso8601String(),
      'deliveryDate': deliveryDate?.toUtc().toIso8601String(),
      'note': note,
    };
  }

  void setField(String key, dynamic value) {
    switch (key) {
      case 'serviceId':
        serviceId = value;
        break;
      case 'serviceTypeId':
        serviceTypeId = value;
        break;
      case 'collectionDate':
        collectionDate = value;
        break;
      case 'deliveryDate':
        deliveryDate = value;
        break;
      case 'note':
        note = value;
        break;
      case 'items':
        items = value;
        break;
      default:
        break;
    }
  }
}

class FlashOrderDraftItem {
  String articleId;
  int quantity;
  bool isPremium;
  String? serviceId;
  double unitPrice = 0;
  String? articleName;

  FlashOrderDraftItem({
    required this.articleId,
    required this.quantity,
    this.isPremium = false,
    this.serviceId,
    this.unitPrice = 0,
    this.articleName,
  });

  Map<String, dynamic> toPayload() {
    return {
      'articleId': articleId,
      'quantity': quantity,
      'isPremium': isPremium,
      'unitPrice': unitPrice,
      'articleName': articleName,
      if (serviceId != null) 'serviceId': serviceId,
    };
  }
}

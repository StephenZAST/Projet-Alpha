/// 📋 Modèle Order Draft - Alpha Client App
///
/// Représente une commande en cours de création dans le stepper.
/// Adapté pour l'app client avec les champs nécessaires.
class OrderDraft {
  String? addressId;
  String? serviceId;
  String? serviceTypeId;
  List<OrderDraftItem> items = [];
  
  // Champs additionnels pour la commande
  String? note;
  DateTime? collectionDate;
  DateTime? deliveryDate;
  String? paymentMethod;
  String? affiliateCode;
  String? recurrenceType;
  DateTime? nextRecurrenceDate;

  OrderDraft({
    this.addressId,
    this.serviceId,
    this.serviceTypeId,
    List<OrderDraftItem>? items,
    this.note,
    this.collectionDate,
    this.deliveryDate,
    this.paymentMethod,
    this.affiliateCode,
    this.recurrenceType,
    this.nextRecurrenceDate,
  }) : items = items ?? [];

  /// 📤 Conversion vers payload pour l'API
  Map<String, dynamic> toPayload(String userId) {
    return {
      'userId': userId,
      'addressId': addressId,
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'items': items.map((e) => e.toPayload(serviceTypeId: serviceTypeId)).toList(),
      'collectionDate': collectionDate?.toUtc().toIso8601String(),
      'deliveryDate': deliveryDate?.toUtc().toIso8601String(),
      'paymentMethod': paymentMethod,
      'affiliateCode': affiliateCode,
      'recurrenceType': recurrenceType,
      'nextRecurrenceDate': nextRecurrenceDate?.toUtc().toIso8601String(),
      'note': note,
    };
  }

  /// 🔧 Setter générique pour champs additionnels
  void setField(String key, dynamic value) {
    switch (key) {
      case 'collectionDate':
        collectionDate = value;
        break;
      case 'deliveryDate':
        deliveryDate = value;
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

  /// ✅ Vérifier si la commande est valide
  bool get isValid {
    return addressId != null &&
           serviceId != null &&
           serviceTypeId != null &&
           items.isNotEmpty;
  }

  /// 💰 Calculer le total estimé
  double get estimatedTotal {
    return items.fold(0.0, (sum, item) => sum + item.estimatedPrice);
  }

  /// 📊 Nombre total d'articles
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// 🔄 Copie avec modifications
  OrderDraft copyWith({
    String? addressId,
    String? serviceId,
    String? serviceTypeId,
    List<OrderDraftItem>? items,
    String? note,
    DateTime? collectionDate,
    DateTime? deliveryDate,
    String? paymentMethod,
    String? affiliateCode,
    String? recurrenceType,
    DateTime? nextRecurrenceDate,
  }) {
    return OrderDraft(
      addressId: addressId ?? this.addressId,
      serviceId: serviceId ?? this.serviceId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      items: items ?? List.from(this.items),
      note: note ?? this.note,
      collectionDate: collectionDate ?? this.collectionDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextRecurrenceDate: nextRecurrenceDate ?? this.nextRecurrenceDate,
    );
  }

  /// 🧹 Réinitialiser le draft
  void reset() {
    addressId = null;
    serviceId = null;
    serviceTypeId = null;
    items.clear();
    note = null;
    collectionDate = null;
    deliveryDate = null;
    paymentMethod = null;
    affiliateCode = null;
    recurrenceType = null;
    nextRecurrenceDate = null;
  }

  @override
  String toString() {
    return 'OrderDraft(addressId: $addressId, serviceId: $serviceId, items: ${items.length}, total: €${estimatedTotal.toStringAsFixed(2)})';
  }
}

/// 📦 Item de commande en draft
class OrderDraftItem {
  final String articleId;
  final String articleName;
  final String? articleDescription;
  final int quantity;
  final bool isPremium;
  final double basePrice;
  final double? premiumPrice;
  final double? weight;
  final String? serviceId;

  OrderDraftItem({
    required this.articleId,
    required this.articleName,
    this.articleDescription,
    required this.quantity,
    this.isPremium = false,
    required this.basePrice,
    this.premiumPrice,
    this.weight,
    this.serviceId,
  });

  /// 💰 Prix unitaire selon le type
  double get unitPrice => isPremium ? (premiumPrice ?? basePrice) : basePrice;

  /// 💰 Prix total de l'item
  double get estimatedPrice => unitPrice * quantity;

  /// 📤 Conversion vers payload pour l'API
  Map<String, dynamic> toPayload({String? serviceTypeId}) {
    return {
      'articleId': articleId,
      'quantity': quantity,
      'isPremium': isPremium,
      'weight': weight,
      if (serviceTypeId != null) 'serviceTypeId': serviceTypeId,
      if (serviceId != null) 'serviceId': serviceId,
    };
  }

  /// 🔄 Copie avec modifications
  OrderDraftItem copyWith({
    String? articleId,
    String? articleName,
    String? articleDescription,
    int? quantity,
    bool? isPremium,
    double? basePrice,
    double? premiumPrice,
    double? weight,
    String? serviceId,
  }) {
    return OrderDraftItem(
      articleId: articleId ?? this.articleId,
      articleName: articleName ?? this.articleName,
      articleDescription: articleDescription ?? this.articleDescription,
      quantity: quantity ?? this.quantity,
      isPremium: isPremium ?? this.isPremium,
      basePrice: basePrice ?? this.basePrice,
      premiumPrice: premiumPrice ?? this.premiumPrice,
      weight: weight ?? this.weight,
      serviceId: serviceId ?? this.serviceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDraftItem && 
           other.articleId == articleId && 
           other.isPremium == isPremium;
  }

  @override
  int get hashCode => Object.hash(articleId, isPremium);

  @override
  String toString() {
    return 'OrderDraftItem(article: $articleName, qty: $quantity, price: €${estimatedPrice.toStringAsFixed(2)})';
  }
}
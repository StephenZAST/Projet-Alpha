import 'package:flutter/material.dart';

/// ⚡ Modèles de Commande Flash - Alpha Client App
///
/// Modèles de données pour les commandes flash selon le backend Alpha Pressing
/// Référence: backend/docs/REFERENCE_ARTICLE_SERVICE.md

/// 🛍️ Item de Commande Flash
class FlashOrderItem {
  final String articleId;
  final String articleName;
  final String serviceId;
  final String serviceName;
  final String serviceTypeId;
  final String serviceTypeName;
  final int quantity;
  final double estimatedPrice;
  final bool isPremium;
  final String? notes;

  FlashOrderItem({
    required this.articleId,
    required this.articleName,
    required this.serviceId,
    required this.serviceName,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.quantity,
    required this.estimatedPrice,
    this.isPremium = false,
    this.notes,
  });

  /// 💰 Prix total de l'item
  double get totalPrice => estimatedPrice * quantity;

  /// 📊 Conversion vers JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'serviceId': serviceId,
      'serviceTypeId': serviceTypeId,
      'quantity': quantity,
      'isPremium': isPremium,
      'notes': notes,
    };
  }

  /// 📥 Création depuis JSON
  factory FlashOrderItem.fromJson(Map<String, dynamic> json) {
    return FlashOrderItem(
      articleId: json['articleId'],
      articleName: json['articleName'] ?? '',
      serviceId: json['serviceId'],
      serviceName: json['serviceName'] ?? '',
      serviceTypeId: json['serviceTypeId'],
      serviceTypeName: json['serviceTypeName'] ?? '',
      quantity: json['quantity'],
      estimatedPrice: (json['estimatedPrice'] ?? 0).toDouble(),
      isPremium: json['isPremium'] ?? false,
      notes: json['notes'],
    );
  }

  /// 🔄 Copie avec modifications
  FlashOrderItem copyWith({
    String? articleId,
    String? articleName,
    String? serviceId,
    String? serviceName,
    String? serviceTypeId,
    String? serviceTypeName,
    int? quantity,
    double? estimatedPrice,
    bool? isPremium,
    String? notes,
  }) {
    return FlashOrderItem(
      articleId: articleId ?? this.articleId,
      articleName: articleName ?? this.articleName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      quantity: quantity ?? this.quantity,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isPremium: isPremium ?? this.isPremium,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'FlashOrderItem(article: $articleName, service: $serviceName, qty: $quantity, price: €$estimatedPrice)';
  }
}

/// ⚡ Commande Flash Complète
class FlashOrder {
  final List<FlashOrderItem> items;
  final String? pickupAddressId;
  final String? deliveryAddressId;
  final String? notes;
  final DateTime? preferredPickupDate;
  final DateTime? preferredDeliveryDate;
  final bool useDefaultAddresses;

  FlashOrder({
    required this.items,
    this.pickupAddressId,
    this.deliveryAddressId,
    this.notes,
    this.preferredPickupDate,
    this.preferredDeliveryDate,
    this.useDefaultAddresses = true,
  });

  /// 💰 Prix total estimé
  double get totalEstimatedPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// 📊 Nombre total d'articles
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// ✅ Validation de la commande
  bool get isValid {
    return items.isNotEmpty &&
        (useDefaultAddresses ||
            (pickupAddressId != null && deliveryAddressId != null));
  }

  /// 📊 Conversion vers JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'pickupAddressId': pickupAddressId,
      'deliveryAddressId': deliveryAddressId,
      'notes': notes,
      'preferredPickupDate': preferredPickupDate?.toIso8601String(),
      'preferredDeliveryDate': preferredDeliveryDate?.toIso8601String(),
      'useDefaultAddresses': useDefaultAddresses,
      'type': 'FLASH', // Identifier le type de commande
    };
  }

  /// 🔄 Copie avec modifications
  FlashOrder copyWith({
    List<FlashOrderItem>? items,
    String? pickupAddressId,
    String? deliveryAddressId,
    String? notes,
    DateTime? preferredPickupDate,
    DateTime? preferredDeliveryDate,
    bool? useDefaultAddresses,
  }) {
    return FlashOrder(
      items: items ?? this.items,
      pickupAddressId: pickupAddressId ?? this.pickupAddressId,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      notes: notes ?? this.notes,
      preferredPickupDate: preferredPickupDate ?? this.preferredPickupDate,
      preferredDeliveryDate:
          preferredDeliveryDate ?? this.preferredDeliveryDate,
      useDefaultAddresses: useDefaultAddresses ?? this.useDefaultAddresses,
    );
  }
}

/// 📋 Résultat de Commande Flash
class FlashOrderResult {
  final bool isSuccess;
  final String? orderId;
  final String? orderReference;
  final FlashOrderStatus status;
  final String? message;
  final String? error;
  final double? finalPrice;
  final DateTime? estimatedCompletion;

  FlashOrderResult._({
    required this.isSuccess,
    this.orderId,
    this.orderReference,
    required this.status,
    this.message,
    this.error,
    this.finalPrice,
    this.estimatedCompletion,
  });

  /// ✅ Résultat de succès
  factory FlashOrderResult.success({
    required String orderId,
    required String orderReference,
    String? message,
    double? finalPrice,
    DateTime? estimatedCompletion,
  }) {
    return FlashOrderResult._(
      isSuccess: true,
      orderId: orderId,
      orderReference: orderReference,
      status: FlashOrderStatus.draft,
      message: message ?? 'Commande flash créée avec succès !',
      finalPrice: finalPrice,
      estimatedCompletion: estimatedCompletion,
    );
  }

  /// ❌ Résultat d'erreur
  factory FlashOrderResult.error(String error) {
    return FlashOrderResult._(
      isSuccess: false,
      status: FlashOrderStatus.failed,
      error: error,
    );
  }

  /// 📥 Création depuis JSON API
  factory FlashOrderResult.fromJson(Map<String, dynamic> json) {
    return FlashOrderResult._(
      isSuccess: json['success'] ?? false,
      orderId: json['orderId'],
      orderReference: json['orderReference'],
      status: FlashOrderStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == json['status']?.toLowerCase(),
        orElse: () => FlashOrderStatus.draft,
      ),
      message: json['message'],
      error: json['error'],
      finalPrice: json['finalPrice']?.toDouble(),
      estimatedCompletion: json['estimatedCompletion'] != null
          ? DateTime.parse(json['estimatedCompletion'])
          : null,
    );
  }
}

/// 📊 Statuts de Commande Flash
enum FlashOrderStatus {
  draft, // Brouillon créé, en attente de validation admin
  confirmed, // Confirmée par l'admin
  processing, // En cours de traitement
  ready, // Prête pour récupération
  delivered, // Livrée
  cancelled, // Annulée
  failed, // Échec de création
}

extension FlashOrderStatusExtension on FlashOrderStatus {
  /// 📝 Nom d'affichage
  String get displayName {
    switch (this) {
      case FlashOrderStatus.draft:
        return 'Brouillon';
      case FlashOrderStatus.confirmed:
        return 'Confirmée';
      case FlashOrderStatus.processing:
        return 'En cours';
      case FlashOrderStatus.ready:
        return 'Prête';
      case FlashOrderStatus.delivered:
        return 'Livrée';
      case FlashOrderStatus.cancelled:
        return 'Annulée';
      case FlashOrderStatus.failed:
        return 'Échec';
    }
  }

  /// 🎨 Couleur associée
  Color get color {
    switch (this) {
      case FlashOrderStatus.draft:
        return const Color(0xFFF59E0B); // Ambre
      case FlashOrderStatus.confirmed:
        return const Color(0xFF3B82F6); // Bleu
      case FlashOrderStatus.processing:
        return const Color(0xFF06B6D4); // Cyan
      case FlashOrderStatus.ready:
        return const Color(0xFF10B981); // Vert
      case FlashOrderStatus.delivered:
        return const Color(0xFF6B7280); // Gris
      case FlashOrderStatus.cancelled:
        return const Color(0xFFEF4444); // Rouge
      case FlashOrderStatus.failed:
        return const Color(0xFFEF4444); // Rouge
    }
  }

  /// 🔄 Icône associée
  IconData get icon {
    switch (this) {
      case FlashOrderStatus.draft:
        return Icons.edit_outlined;
      case FlashOrderStatus.confirmed:
        return Icons.check_circle_outline;
      case FlashOrderStatus.processing:
        return Icons.refresh;
      case FlashOrderStatus.ready:
        return Icons.check_circle;
      case FlashOrderStatus.delivered:
        return Icons.done_all;
      case FlashOrderStatus.cancelled:
        return Icons.cancel_outlined;
      case FlashOrderStatus.failed:
        return Icons.error_outline;
    }
  }
}

/// 🎯 Articles Populaires pour Commande Flash
class PopularFlashItem {
  final String articleId;
  final String articleName;
  final String serviceId;
  final String serviceName;
  final String serviceTypeId;
  final String serviceTypeName;
  final double basePrice;
  final String iconName;
  final Color color;
  final bool isPopular;

  PopularFlashItem({
    required this.articleId,
    required this.articleName,
    required this.serviceId,
    required this.serviceName,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.basePrice,
    required this.iconName,
    required this.color,
    this.isPopular = false,
  });

  /// 🔄 Conversion vers FlashOrderItem
  FlashOrderItem toFlashOrderItem({int quantity = 1, bool isPremium = false}) {
    return FlashOrderItem(
      articleId: articleId,
      articleName: articleName,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceTypeId: serviceTypeId,
      serviceTypeName: serviceTypeName,
      quantity: quantity,
      estimatedPrice: isPremium ? basePrice * 1.5 : basePrice,
      isPremium: isPremium,
    );
  }

  /// 📊 Conversion depuis JSON
  factory PopularFlashItem.fromJson(Map<String, dynamic> json) {
    return PopularFlashItem(
      articleId: json['articleId'],
      articleName: json['articleName'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      serviceTypeId: json['serviceTypeId'],
      serviceTypeName: json['serviceTypeName'],
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      iconName: json['iconName'] ?? 'checkroom',
      color: Color(json['color'] ?? 0xFF2563EB),
      isPopular: json['isPopular'] ?? false,
    );
  }
}

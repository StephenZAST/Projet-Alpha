class Order {
  final String id;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem>? items;
  final String? deliveryAddress;
  final String? notes;
  final bool isPaid;

  Order({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.updatedAt,
    this.items,
    this.deliveryAddress,
    this.notes,
    required this.isPaid,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      return Order(
        id: json['id']?.toString() ??
            '', // Convertir en String et valeur par défaut
        customerId: json['customerId']?.toString(),
        customerName: json['customerName']?.toString(),
        customerEmail: json['customerEmail']?.toString(),
        customerPhone: json['customerPhone']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
        totalAmount: json['totalAmount'] != null
            ? (json['totalAmount'] as num).toDouble()
            : 0.0, // Valeur par défaut si null
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(), // Valeur par défaut
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
        items: json['items'] != null
            ? (json['items'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList()
            : null,
        deliveryAddress: json['deliveryAddress']?.toString(),
        notes: json['notes']?.toString(),
        isPaid: json['isPaid'] ?? false,
      );
    } catch (e) {
      print('Error parsing Order JSON: $e');
      print('Problematic JSON: $json');
      // Retourner un ordre "vide" mais valide en cas d'erreur
      return Order(
        id: json['id']?.toString() ?? 'error',
        status: 'ERROR',
        totalAmount: 0,
        createdAt: DateTime.now(),
        isPaid: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'isPaid': isPaid,
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? status,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    String? deliveryAddress,
    String? notes,
    bool? isPaid,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final double? discount;
  final String? notes;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.discount,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed Item',
        quantity:
            json['quantity'] != null ? (json['quantity'] as num).toInt() : 1,
        price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
        discount: json['discount'] != null
            ? (json['discount'] as num).toDouble()
            : null,
        notes: json['notes']?.toString(),
      );
    } catch (e) {
      print('Error parsing OrderItem JSON: $e');
      print('Problematic JSON: $json');
      // Retourner un item "vide" mais valide en cas d'erreur
      return OrderItem(
        id: '',
        name: 'Error Item',
        quantity: 1,
        price: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'notes': notes,
    };
  }

  double get total => (price * quantity) - (discount ?? 0);
}

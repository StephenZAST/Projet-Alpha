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
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      status: json['status'] ?? 'PENDING',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : null,
      deliveryAddress: json['deliveryAddress'],
      notes: json['notes'],
      isPaid: json['isPaid'] ?? false,
    );
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
    return OrderItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      notes: json['notes'],
    );
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

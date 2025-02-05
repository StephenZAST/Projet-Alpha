class OrderMetadata {
  final String orderId;
  final bool isFlashOrder;
  final String? note;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderMetadata({
    required this.orderId,
    required this.isFlashOrder,
    this.note,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderMetadata.fromJson(Map<String, dynamic> json) {
    return OrderMetadata(
      orderId: json['order_id'],
      isFlashOrder: json['is_flash_order'] ?? false,
      note: json['metadata']?['note'],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

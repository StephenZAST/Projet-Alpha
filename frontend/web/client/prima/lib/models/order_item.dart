class OrderItem {
  final String id;
  final String orderId;
  final String articleId;
  final String serviceId;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.articleId,
    required this.serviceId,
    required this.quantity,
    required this.unitPrice,
  });
}

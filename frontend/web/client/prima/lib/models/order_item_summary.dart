class OrderItemSummary {
  final String name;
  final int quantity;
  final double unitPrice;

  OrderItemSummary({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

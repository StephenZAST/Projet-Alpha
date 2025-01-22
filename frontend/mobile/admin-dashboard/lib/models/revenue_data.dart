class RevenueData {
  final String period;
  final double amount;
  final double? previousAmount;

  RevenueData({
    required this.period,
    required this.amount,
    this.previousAmount,
  });

  double get growth {
    if (previousAmount == null || previousAmount == 0) return 0;
    return ((amount - previousAmount!) / previousAmount!) * 100;
  }

  bool get isPositiveGrowth => growth >= 0;
}

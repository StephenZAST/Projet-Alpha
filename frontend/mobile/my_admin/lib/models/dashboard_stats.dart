class DashboardStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;

  DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalCustomers,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: double.parse(json['totalRevenue'].toString()),
      totalOrders: json['totalOrders'],
      totalCustomers: json['totalCustomers'],
    );
  }
}

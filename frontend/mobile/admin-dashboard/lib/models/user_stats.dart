class UserStats {
  final int clientCount;
  final int affiliateCount;
  final int adminCount;
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final Map<String, dynamic> revenueStats;

  UserStats({
    required this.clientCount,
    required this.affiliateCount,
    required this.adminCount,
    required this.totalUsers,
    this.activeUsers = 0,
    this.inactiveUsers = 0,
    this.revenueStats = const {},
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      clientCount: json['clientCount'] ?? 0,
      affiliateCount: json['affiliateCount'] ?? 0,
      adminCount: json['adminCount'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      inactiveUsers: json['inactiveUsers'] ?? 0,
      revenueStats: json['revenueStats'] ?? {},
    );
  }
}

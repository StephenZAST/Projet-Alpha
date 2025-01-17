class LoyaltyPoints {
  final String id;
  final String userId;
  final int pointsBalance;
  final int totalEarned;
  final DateTime createdAt;

  LoyaltyPoints({
    required this.id,
    required this.userId,
    required this.pointsBalance,
    required this.totalEarned,
    required this.createdAt,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      id: json['id'],
      userId: json['userId'],
      pointsBalance: json['pointsBalance'],
      totalEarned: json['totalEarned'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

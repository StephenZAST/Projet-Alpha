class LoyaltyPoints {
  final String id;
  final String userId;
  final int pointsBalance;
  final int totalEarned;
  final DateTime createdAt;

  const LoyaltyPoints({
    required this.id,
    required this.userId,
    required this.pointsBalance,
    required this.totalEarned,
    required this.createdAt,
  });

  bool canSpendPoints(int amount) => pointsBalance >= amount;

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      id: json['id'],
      userId: json['userId'],
      pointsBalance: json['pointsBalance'],
      totalEarned: json['totalEarned'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'pointsBalance': pointsBalance,
        'totalEarned': totalEarned,
        'createdAt': createdAt.toIso8601String(),
      };
}

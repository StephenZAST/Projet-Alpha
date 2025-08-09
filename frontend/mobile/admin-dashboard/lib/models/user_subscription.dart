class UserSubscription {
  final String id;
  final String userId;
  final String? userName;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'ACTIVE', 'CANCELLED', 'EXPIRED'
  final int remainingOrders;
  final double? remainingWeight;
  final bool expired;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscription({
    required this.id,
    required this.userId,
    this.userName,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.remainingOrders,
    this.remainingWeight,
    required this.expired,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      userName: json['userName'] ?? json['user_name'],
      planId: json['planId'] ?? json['plan_id'] ?? '',
      startDate: DateTime.parse(json['startDate'] ??
          json['start_date'] ??
          DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ??
          json['end_date'] ??
          DateTime.now().toIso8601String()),
      status: json['status'] ?? 'ACTIVE',
      remainingOrders: json['remainingOrders'] ?? json['remaining_orders'] ?? 0,
      remainingWeight:
          (json['remainingWeight'] ?? json['remaining_weight'])?.toDouble(),
      expired: json['expired'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ??
          json['updated_at'] ??
          DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'planId': planId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'remainingOrders': remainingOrders,
        'remainingWeight': remainingWeight,
        'expired': expired,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

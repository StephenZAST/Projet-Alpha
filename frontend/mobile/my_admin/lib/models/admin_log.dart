class AdminLog {
  final String id;
  final String adminName;
  final String action;
  final String entityType;
  final String entityId;
  final DateTime createdAt;

  AdminLog({
    required this.id,
    required this.adminName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
  });

  factory AdminLog.fromJson(Map<String, dynamic> json) {
    return AdminLog(
      id: json['id'],
      adminName: json['adminName'],
      action: json['action'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

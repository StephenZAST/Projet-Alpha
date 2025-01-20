class AdminLog {
  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> changes;
  final DateTime createdAt;

  AdminLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.changes,
    required this.createdAt,
  });
}

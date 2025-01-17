class PointTransaction {
  final String id;
  final String userId;
  final int points;
  final String type;
  final String source;
  final String referenceId;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.source,
    required this.referenceId,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'],
      userId: json['userId'],
      points: json['points'],
      type: json['type'],
      source: json['source'],
      referenceId: json['referenceId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

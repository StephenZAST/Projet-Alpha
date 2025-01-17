enum TransactionType { EARNED, SPENT }

enum TransactionSource { ORDER, REFERRAL, REWARD, EXCHANGE }

class PointTransaction {
  final String id;
  final String userId;
  final int points;
  final TransactionType type;
  final TransactionSource source;
  final String referenceId;
  final DateTime createdAt;
  final String? description;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.source,
    required this.referenceId,
    required this.createdAt,
    this.description,
  });

  bool get isEarned => type == TransactionType.EARNED;

  String getSourceText() {
    return switch (source) {
      TransactionSource.ORDER => 'Commande',
      TransactionSource.REFERRAL => 'Parrainage',
      TransactionSource.REWARD => 'Récompense',
      TransactionSource.EXCHANGE => 'Conversion en réduction',
    };
  }

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'],
      userId: json['userId'],
      points: json['points'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      source: TransactionSource.values.firstWhere(
        (e) => e.toString().split('.').last == json['source'],
      ),
      referenceId: json['referenceId'],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
    );
  }
}

class ArticleService {
  final String id;
  final String articleId;
  final String serviceId;
  final double priceMultiplier;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ArticleService({
    required this.id,
    required this.articleId,
    required this.serviceId,
    required this.priceMultiplier,
    required this.createdAt,
    this.updatedAt,
  });

  factory ArticleService.fromJson(Map<String, dynamic> json) {
    return ArticleService(
      id: json['id'],
      articleId: json['articleId'],
      serviceId: json['serviceId'],
      priceMultiplier: (json['priceMultiplier'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'serviceId': serviceId,
      'priceMultiplier': priceMultiplier,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ArticleServiceCreateDTO {
  final String articleId;
  final String serviceId;
  final double priceMultiplier;

  ArticleServiceCreateDTO({
    required this.articleId,
    required this.serviceId,
    required this.priceMultiplier,
  });

  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'serviceId': serviceId,
      'priceMultiplier': priceMultiplier,
    };
  }
}

class ArticleServiceUpdateDTO {
  final double priceMultiplier;

  ArticleServiceUpdateDTO({
    required this.priceMultiplier,
  });

  Map<String, dynamic> toJson() {
    return {
      'priceMultiplier': priceMultiplier,
    };
  }
}

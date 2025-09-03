class Offer {
  final String id;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final bool isCumulative;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? pointsRequired;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OfferArticle> articles;

  Offer({
    required this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    required this.isCumulative,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.pointsRequired,
    required this.createdAt,
    required this.updatedAt,
    this.articles = const [],
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      minPurchaseAmount: json['minPurchaseAmount'] != null 
          ? (json['minPurchaseAmount'] as num).toDouble() 
          : null,
      maxDiscountAmount: json['maxDiscountAmount'] != null 
          ? (json['maxDiscountAmount'] as num).toDouble() 
          : null,
      isCumulative: json['isCumulative'] ?? false,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
      pointsRequired: json['pointsRequired'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      articles: json['articles'] != null
          ? (json['articles'] as List)
              .map((article) => OfferArticle.fromJson(article))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchaseAmount': minPurchaseAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'isCumulative': isCumulative,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'pointsRequired': pointsRequired,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'articles': articles.map((article) => article.toJson()).toList(),
    };
  }

  // Méthode pour convertir en Map<String, dynamic> pour compatibilité
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchaseAmount': minPurchaseAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'isCumulative': isCumulative,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'pointsRequired': pointsRequired,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'articles': articles.map((article) => article.toMap()).toList(),
    };
  }
}

class OfferArticle {
  final String id;
  final String name;
  final String? description;

  OfferArticle({
    required this.id,
    required this.name,
    this.description,
  });

  factory OfferArticle.fromJson(Map<String, dynamic> json) {
    return OfferArticle(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class CreateOfferDTO {
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final bool isCumulative;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? pointsRequired;
  final List<String>? articleIds;

  CreateOfferDTO({
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    required this.isCumulative,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.pointsRequired,
    this.articleIds,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'isCumulative': isCumulative,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };

    if (minPurchaseAmount != null) data['minPurchaseAmount'] = minPurchaseAmount;
    if (maxDiscountAmount != null) data['maxDiscountAmount'] = maxDiscountAmount;
    if (pointsRequired != null) data['pointsRequired'] = pointsRequired;
    if (articleIds != null && articleIds!.isNotEmpty) data['articleIds'] = articleIds;

    return data;
  }
}

class UpdateOfferDTO {
  final String? name;
  final String? description;
  final String? discountType;
  final double? discountValue;
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final bool? isCumulative;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;
  final int? pointsRequired;
  final List<String>? articleIds;

  UpdateOfferDTO({
    this.name,
    this.description,
    this.discountType,
    this.discountValue,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    this.isCumulative,
    this.startDate,
    this.endDate,
    this.isActive,
    this.pointsRequired,
    this.articleIds,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (discountType != null) data['discountType'] = discountType;
    if (discountValue != null) data['discountValue'] = discountValue;
    if (minPurchaseAmount != null) data['minPurchaseAmount'] = minPurchaseAmount;
    if (maxDiscountAmount != null) data['maxDiscountAmount'] = maxDiscountAmount;
    if (isCumulative != null) data['isCumulative'] = isCumulative;
    if (startDate != null) data['startDate'] = startDate!.toIso8601String();
    if (endDate != null) data['endDate'] = endDate!.toIso8601String();
    if (isActive != null) data['isActive'] = isActive;
    if (pointsRequired != null) data['pointsRequired'] = pointsRequired;
    if (articleIds != null) data['articleIds'] = articleIds;

    return data;
  }
}
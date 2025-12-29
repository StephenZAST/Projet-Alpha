/**
 * 📝 Blog Article Model - Modèle pour les articles de blog
 */

class BlogArticle {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final String? categoryId;
  final String? authorId;
  final String? featuredImage;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int readingTime;
  final List<String> seoKeywords;
  final String? seoDescription;
  final int viewsCount;
  final bool isPublished;
  final BlogCategory? category;
  final BlogAuthor? author;

  BlogArticle({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    this.categoryId,
    this.authorId,
    this.featuredImage,
    this.publishedAt,
    this.updatedAt,
    this.createdAt,
    this.readingTime = 5,
    this.seoKeywords = const [],
    this.seoDescription,
    this.viewsCount = 0,
    this.isPublished = false,
    this.category,
    this.author,
  });

  factory BlogArticle.fromJson(Map<String, dynamic> json) {
    return BlogArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'] ?? '',
      categoryId: json['category_id'],
      authorId: json['author_id'],
      featuredImage: json['featured_image'],
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      readingTime: json['reading_time'] ?? 5,
      seoKeywords: List<String>.from(json['seo_keywords'] ?? []),
      seoDescription: json['seo_description'],
      viewsCount: json['views_count'] ?? 0,
      isPublished: json['is_published'] ?? false,
      category: json['category'] != null ? BlogCategory.fromJson(json['category']) : null,
      author: json['author'] != null ? BlogAuthor.fromJson(json['author']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'category_id': categoryId,
      'author_id': authorId,
      'featured_image': featuredImage,
      'published_at': publishedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'reading_time': readingTime,
      'seo_keywords': seoKeywords,
      'seo_description': seoDescription,
      'views_count': viewsCount,
      'is_published': isPublished,
    };
  }

  BlogArticle copyWith({
    String? id,
    String? title,
    String? slug,
    String? content,
    String? excerpt,
    String? categoryId,
    String? authorId,
    String? featuredImage,
    DateTime? publishedAt,
    DateTime? updatedAt,
    DateTime? createdAt,
    int? readingTime,
    List<String>? seoKeywords,
    String? seoDescription,
    int? viewsCount,
    bool? isPublished,
    BlogCategory? category,
    BlogAuthor? author,
  }) {
    return BlogArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      categoryId: categoryId ?? this.categoryId,
      authorId: authorId ?? this.authorId,
      featuredImage: featuredImage ?? this.featuredImage,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      readingTime: readingTime ?? this.readingTime,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      seoDescription: seoDescription ?? this.seoDescription,
      viewsCount: viewsCount ?? this.viewsCount,
      isPublished: isPublished ?? this.isPublished,
      category: category ?? this.category,
      author: author ?? this.author,
    );
  }

  @override
  String toString() => 'BlogArticle(id: $id, title: $title, slug: $slug)';
}

class BlogCategory {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BlogCategory({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'BlogCategory(id: $id, name: $name)';
}

class BlogAuthor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  BlogAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
    return BlogAuthor(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }

  String get fullName => '$firstName $lastName';

  @override
  String toString() => 'BlogAuthor(id: $id, name: $fullName)';
}

class BlogArticleResponse {
  final List<BlogArticle> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  BlogArticleResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory BlogArticleResponse.fromJson(Map<String, dynamic> json) {
    return BlogArticleResponse(
      data: (json['data'] as List?)?.map((e) => BlogArticle.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 12,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  @override
  String toString() => 'BlogArticleResponse(total: $total, page: $page)';
}

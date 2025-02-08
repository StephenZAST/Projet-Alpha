class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int currentPage;
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });
}

class PaginationData {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationData({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  factory PaginationData.empty() {
    return PaginationData(
      total: 0,
      page: 1,
      limit: 10,
      totalPages: 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
      };
}

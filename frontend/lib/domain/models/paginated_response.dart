class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginatedResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      currentPage: json['current_page'],
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPreviousPage => prevPageUrl != null;
} 
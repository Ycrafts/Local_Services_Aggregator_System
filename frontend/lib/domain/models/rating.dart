class Rating {
  final int id;
  final double rating;
  final String? comment;
  final int jobId;
  final int customerProfileId;
  final int providerProfileId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.rating,
    this.comment,
    required this.jobId,
    required this.customerProfileId,
    required this.providerProfileId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as int,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      comment: json['comment'] as String?,
      jobId: json['job_id'] as int,
      customerProfileId: json['customer_profile_id'] as int,
      providerProfileId: json['provider_profile_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'job_id': jobId,
      'customer_profile_id': customerProfileId,
      'provider_profile_id': providerProfileId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 
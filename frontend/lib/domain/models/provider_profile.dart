import 'package:local_services_aggregator_mobile/domain/models/user.dart';
import 'package:local_services_aggregator_mobile/domain/models/job_type.dart';

class ProviderProfile {
  final int id;
  final String? bio;
  final String address;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final List<JobType> jobTypes;

  ProviderProfile({
    required this.id,
    this.bio,
    required this.address,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.jobTypes,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as int,
      bio: json['bio'] as String?,
      address: json['address'] as String,
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      jobTypes: (json['job_types'] as List)
          .map((e) => JobType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'address': address,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'job_types': jobTypes.map((e) => e.toJson()).toList(),
    };
  }
} 
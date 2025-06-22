import 'job_status.dart';
import 'job_type.dart';
import 'user.dart';
import 'customer_profile.dart';
import 'rating.dart';
import 'package:flutter/foundation.dart';

class Job {
  final int id;
  final String title;
  final String description;
  final double proposedPrice;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JobType jobType;
  final User? assignedProvider;
  final CustomerProfile? customerProfile;
  final Rating? rating;
  final bool hasRating;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.proposedPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.jobType,
    this.assignedProvider,
    this.customerProfile,
    this.rating,
    this.hasRating = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    debugPrint('Job.fromJson received JSON: $json');
    return Job(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      proposedPrice: double.tryParse(json['proposed_price']?.toString() ?? '') ?? 0.0,
      status: json['status'] != null ? JobStatus.fromString(json['status']) : JobStatus.open,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      jobType: json['job_type'] != null ? JobType.fromJson(json['job_type']) : JobType(id: 0, name: 'Unknown', baselinePrice: '0.0'),
      assignedProvider: (json['assigned_provider'] != null && json['assigned_provider']['user'] != null)
          ? User.fromJson(json['assigned_provider']['user'])
          : null,
      customerProfile: json['customer_profile'] != null
          ? CustomerProfile.fromJson(json['customer_profile'])
          : null,
      rating: (json['rating'] is List && (json['rating'] as List).isNotEmpty)
          ? Rating.fromJson(json['rating'][0])
          : null,
      hasRating: json['has_rating'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'proposed_price': proposedPrice,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'job_type': jobType.toJson(),
      'assigned_provider': assignedProvider?.toJson(),
      'customer_profile': customerProfile?.toJson(),
      'rating': rating?.toJson(),
    };
  }
} 
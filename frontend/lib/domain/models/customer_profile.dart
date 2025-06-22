import 'user.dart';

class CustomerProfile {
  final String address;
  final String? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  CustomerProfile({
    required this.address,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      address: json['address'] ?? '',
      additionalInfo: json['additional_info'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'additional_info': additionalInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
} 
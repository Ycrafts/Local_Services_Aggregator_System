import 'package:local_services_aggregator_mobile/domain/models/user.dart';

class InterestedProvider {
  final int id;
  final bool isInterested;
  final bool isSelected;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProviderProfile providerProfile;

  InterestedProvider({
    required this.id,
    required this.isInterested,
    required this.isSelected,
    required this.createdAt,
    required this.updatedAt,
    required this.providerProfile,
  });

  factory InterestedProvider.fromJson(Map<String, dynamic> json) {
    return InterestedProvider(
      id: json['id'],
      isInterested: json['is_interested'],
      isSelected: json['is_selected'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      providerProfile: ProviderProfile.fromJson(json['provider_profile']),
    );
  }
}

class ProviderProfile {
  final int id;
  final String rating;
  final String bio;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  ProviderProfile({
    required this.id,
    required this.rating,
    required this.bio,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'],
      rating: json['rating'],
      bio: json['bio'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: User.fromJson(json['user']),
    );
  }
} 
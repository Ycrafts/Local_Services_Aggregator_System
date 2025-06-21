import 'package:local_services_aggregator_mobile/core/network/api_client.dart';
import 'package:local_services_aggregator_mobile/core/config/api_config.dart';
import 'package:local_services_aggregator_mobile/domain/models/provider_profile.dart';
import 'package:dio/dio.dart';

class ProviderProfileRepository {
  final ApiClient _apiClient;

  ProviderProfileRepository(this._apiClient);

  Future<ProviderProfile?> getProviderProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.providerProfile);
      return ProviderProfile.fromJson(response.data['profile']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> createProviderProfile({
    String? bio,
    required String address,
    required List<int> jobTypeIds,
  }) async {
    try {
      await _apiClient.post(
        ApiConfig.providerProfile,
        data: {
          'bio': bio,
          'address': address,
          'job_type_ids': jobTypeIds,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProviderProfile({
    String? bio,
    required String address,
    List<int>? jobTypeIds,
  }) async {
    try {
      await _apiClient.put(
        ApiConfig.providerProfile,
        data: {
          'bio': bio,
          'address': address,
          'job_type_ids': jobTypeIds,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
} 
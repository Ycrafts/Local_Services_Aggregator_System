import 'package:local_services_aggregator_mobile/core/network/api_client.dart';
import 'package:local_services_aggregator_mobile/core/config/api_config.dart';
import 'package:local_services_aggregator_mobile/domain/models/customer_profile.dart';
import 'package:dio/dio.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<CustomerProfile?> getCustomerProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.customerProfile);
      return CustomerProfile.fromJson(response.data['profile']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> createCustomerProfile({
    required String address,
    required String additionalInfo,
  }) async {
    try {
      await _apiClient.post(
        ApiConfig.customerProfile,
        data: {
          'address': address,
          'additional_info': additionalInfo,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCustomerProfile({
    required String address,
    required String additionalInfo,
  }) async {
    try {
      await _apiClient.put(
        ApiConfig.customerProfile,
        data: {
          'address': address,
          'additional_info': additionalInfo,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
} 
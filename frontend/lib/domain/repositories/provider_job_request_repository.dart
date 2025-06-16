import 'package:local_services_aggregator_mobile/core/network/api_client.dart';
import 'package:local_services_aggregator_mobile/core/config/api_config.dart';
import 'package:local_services_aggregator_mobile/domain/models/provider_job_request.dart';
import 'package:local_services_aggregator_mobile/domain/models/paginated_response.dart';

class ProviderJobRequestRepository {
  final ApiClient _apiClient;

  ProviderJobRequestRepository(this._apiClient);

  Future<PaginatedResponse<ProviderJobRequest>> fetchRequestedJobs({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.requestedJobs,
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(
        response.data,
        (json) => ProviderJobRequest.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedResponse<ProviderJobRequest>> fetchSelectedJobs({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.selectedJobs,
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(
        response.data,
        (json) => ProviderJobRequest.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> expressInterest(int jobId) async {
    try {
      await _apiClient.post(
        ApiConfig.expressInterest.replaceFirst('{jobId}', jobId.toString()),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> providerMarkDone(int jobId) async {
    try {
      await _apiClient.post(
        ApiConfig.providerDone.replaceFirst('{jobId}', jobId.toString()),
      );
    } catch (e) {
      rethrow;
    }
  }
} 
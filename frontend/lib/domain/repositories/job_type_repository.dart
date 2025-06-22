import 'package:local_services_aggregator_mobile/core/config/api_config.dart';
import 'package:local_services_aggregator_mobile/core/network/api_client.dart';
import 'package:local_services_aggregator_mobile/domain/models/job_type.dart';

class JobTypeRepository {
  final ApiClient _apiClient;

  JobTypeRepository(this._apiClient);

  Future<JobTypeResponse> fetchJobTypes({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConfig.jobTypes,
      queryParameters: {'page': page},
    );

    final List<dynamic> jobTypesJson = response.data['data'];
    final jobTypes = jobTypesJson.map((json) => JobType.fromJson(json)).toList();
    
    return JobTypeResponse(
      jobTypes: jobTypes,
      hasMorePages: response.data['next_page_url'] != null,
    );
  }
}

class JobTypeResponse {
  final List<JobType> jobTypes;
  final bool hasMorePages;

  JobTypeResponse({
    required this.jobTypes,
    required this.hasMorePages,
  });
} 
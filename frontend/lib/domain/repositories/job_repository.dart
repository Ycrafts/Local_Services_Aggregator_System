import 'package:local_services_aggregator_mobile/core/network/api_client.dart';
import 'package:local_services_aggregator_mobile/core/config/api_config.dart';
import 'package:local_services_aggregator_mobile/domain/models/job.dart';
import 'package:local_services_aggregator_mobile/domain/models/interested_provider.dart';
import 'package:dio/dio.dart';
import '../models/job_status.dart';
import 'package:flutter/foundation.dart';

class JobRepository {
  final ApiClient _apiClient;
  final Dio _dio;

  JobRepository(this._apiClient, this._dio);

  Future<JobResponse> getCustomerJobs({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConfig.jobs,
      queryParameters: {'page': page},
    );
    final List<dynamic> jobsJson = response.data['data'];
    final jobs = jobsJson.map((json) => Job.fromJson(json)).toList();
    
    return JobResponse(
      jobs: jobs,
      hasMorePages: response.data['next_page_url'] != null,
    );
  }

  Future<Job> getJobDetails(int jobId) async {
    final response = await _apiClient.get('${ApiConfig.jobs}/$jobId');
    return Job.fromJson(response.data);
  }

  Future<void> cancelJob(int jobId) async {
    await _apiClient.post('${ApiConfig.jobs}/$jobId/cancel');
  }

  Future<void> confirmJobCompletion(int jobId) async {
    await _apiClient.post('${ApiConfig.jobs}/$jobId/complete');
  }

  Future<void> rateProvider(int jobId, int rating, String? comment) async {
    await _apiClient.post(
      '${ApiConfig.jobs}/$jobId/rate-provider',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<Job> store({
    required String title,
    required String description,
    required int jobTypeId,
    required double proposedPrice,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.jobs,
        data: {
          'title': title,
          'description': description,
          'job_type_id': jobTypeId,
          'proposed_price': proposedPrice,
        },
      );
      debugPrint('Job creation API response: ${response.data}');
      return Job.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  Future<Job> updateStatus(int jobId, JobStatus status) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.jobs}/$jobId/status',
        data: {
          'status': status.toString().split('.').last,
        },
      );
      return Job.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update job status: $e');
    }
  }

  Future<List<InterestedProvider>> getInterestedProviders(int jobId) async {
    final url = '${ApiConfig.jobs}/$jobId/interested-providers';
    try {
      final response = await _apiClient.get(url);
      return (response.data as List)
          .map((json) => InterestedProvider.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch interested providers: $e');
    }
  }

  Future<Job> selectProvider(int jobId, int providerProfileId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.jobs}/$jobId/select-provider',
        data: {
          'provider_profile_id': providerProfileId,
        },
      );
      debugPrint('Provider selection API response: ${response.data}');
      return Job.fromJson(response.data['job']);
    } catch (e) {
      throw Exception('Failed to select provider: $e');
    }
  }
}

class JobResponse {
  final List<Job> jobs;
  final bool hasMorePages;

  JobResponse({
    required this.jobs,
    required this.hasMorePages,
  });
} 
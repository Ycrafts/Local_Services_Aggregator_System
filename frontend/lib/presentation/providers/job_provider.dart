import 'package:flutter/foundation.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/models/job.dart';
import '../../domain/models/job_status.dart';
import '../../domain/models/interested_provider.dart';

class JobProvider with ChangeNotifier {
  final JobRepository _jobRepository;
  List<Job> _jobs = [];
  List<InterestedProvider> _interestedProviders = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;

  JobProvider(this._jobRepository);

  List<Job> get jobs => _jobs;
  List<InterestedProvider> get interestedProviders => _interestedProviders;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;

  List<Job> getJobsByStatus(JobStatus status) {
    return _jobs.where((job) => job.status == status).toList();
  }

  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<void> fetchJobs({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _jobs.isNotEmpty) {
      debugPrint('JobProvider: fetchJobs - Returning from cache.');
      return;
    }

    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();
    debugPrint('JobProvider: fetchJobs - Started loading jobs.');

    try {
      final result = await _jobRepository.getCustomerJobs(page: _currentPage);
      _jobs = result.jobs;
      _hasMorePages = result.hasMorePages;
      _lastFetchTime = DateTime.now();
      debugPrint('JobProvider: fetchJobs - Successfully fetched jobs.');
    } catch (e) {
      _error = e.toString();
      debugPrint('JobProvider: fetchJobs - Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('JobProvider: fetchJobs - Finished loading jobs, notifying listeners.');
    }
  }

  Future<void> loadMoreJobs() async {
    if (!_hasMorePages || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _jobRepository.getCustomerJobs(page: _currentPage + 1);
      _jobs.addAll(result.jobs);
      _hasMorePages = result.hasMorePages;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> cancelJob(int jobId) async {
    try {
      await _jobRepository.cancelJob(jobId);
      await fetchJobs(forceRefresh: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Job> confirmJobCompletion(int jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('JobProvider: confirmJobCompletion - Started confirming completion for job ID: $jobId');

    try {
      await _jobRepository.confirmJobCompletion(jobId);
      final updatedJob = await _jobRepository.getJobDetails(jobId); // Fetch the updated job details
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
      }
      _error = null;
      debugPrint('JobProvider: confirmJobCompletion - Successfully confirmed completion for job ID: $jobId.');
      return updatedJob; // Return the updated job
    } catch (e) {
      _error = e.toString();
      debugPrint('JobProvider: confirmJobCompletion - Error confirming completion for job ID: $jobId: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('JobProvider: confirmJobCompletion - Finished confirming completion, notifying listeners.');
    }
  }

  Future<void> rateProvider(int jobId, int rating, String? comment) async {
    try {
      await _jobRepository.rateProvider(jobId, rating, comment);
      await fetchJobs(forceRefresh: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearCache() {
    _lastFetchTime = null;
    _jobs = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> createJob({
    required String title,
    required String description,
    required int jobTypeId,
    required double proposedPrice,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('JobProvider: createJob - Started creating job.');

    try {
      final job = await _jobRepository.store(
        title: title,
        description: description,
        jobTypeId: jobTypeId,
        proposedPrice: proposedPrice,
      );
      _jobs.add(job);
      _error = null;
      debugPrint('JobProvider: createJob - Successfully created job.');
      await fetchJobs(forceRefresh: true); // Force refresh after successful job creation
    } catch (e) {
      _error = e.toString();
      debugPrint('JobProvider: createJob - Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('JobProvider: createJob - Finished creating job, notifying listeners.');
    }
  }

  Future<void> updateJobStatus(int jobId, JobStatus status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedJob = await _jobRepository.updateStatus(jobId, status);
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInterestedProviders(int jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _interestedProviders = await _jobRepository.getInterestedProviders(jobId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Job> selectProvider(int jobId, int providerProfileId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('JobProvider: selectProvider - Started selecting provider.');

    try {
      final updatedJob = await _jobRepository.selectProvider(jobId, providerProfileId);
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
      }
      _error = null;
      debugPrint('JobProvider: selectProvider - Successfully selected provider.');
      return updatedJob;
    } catch (e) {
      _error = e.toString();
      debugPrint('JobProvider: selectProvider - Error: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('JobProvider: selectProvider - Finished selecting provider, notifying listeners.');
    }
  }

  Future<Job> getJobDetails(int jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('JobProvider: getJobDetails - Started fetching details for job ID: $jobId');

    try {
      final job = await _jobRepository.getJobDetails(jobId);
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = job;
      } else {
        _jobs.add(job);
      }
      _error = null;
      debugPrint('JobProvider: getJobDetails - Successfully fetched details for job ID: $jobId');
      return job;
    } catch (e) {
      _error = e.toString();
      debugPrint('JobProvider: getJobDetails - Error fetching details for job ID: $jobId: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('JobProvider: getJobDetails - Finished fetching details, notifying listeners.');
    }
  }
} 
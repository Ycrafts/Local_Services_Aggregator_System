import 'package:flutter/foundation.dart';
import '../../domain/repositories/provider_job_request_repository.dart';
import '../../domain/models/provider_job_request.dart';
import '../../domain/models/paginated_response.dart';

class ProviderJobRequestProvider with ChangeNotifier {
  final ProviderJobRequestRepository _repository;
  List<ProviderJobRequest> _requestedJobs = [];
  List<ProviderJobRequest> _selectedJobs = [];
  bool _isRequestedJobsLoading = false;
  bool _isSelectedJobsLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _requestedJobsPage = 1;
  int _selectedJobsPage = 1;
  bool _hasMoreRequestedJobs = true;
  bool _hasMoreSelectedJobs = true;

  ProviderJobRequestProvider(this._repository);

  List<ProviderJobRequest> get requestedJobs => _requestedJobs;
  List<ProviderJobRequest> get selectedJobs => _selectedJobs;
  bool get isLoading => _isRequestedJobsLoading || _isSelectedJobsLoading;
  bool get isRequestedJobsLoading => _isRequestedJobsLoading;
  bool get isSelectedJobsLoading => _isSelectedJobsLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreRequestedJobs => _hasMoreRequestedJobs;
  bool get hasMoreSelectedJobs => _hasMoreSelectedJobs;

  Future<void> fetchRequestedJobs({bool refresh = false}) async {
    if (refresh) {
      _requestedJobsPage = 1;
      _requestedJobs = [];
      _hasMoreRequestedJobs = true;
    }

    if (!refresh && (!_hasMoreRequestedJobs || _isRequestedJobsLoading)) return;

    _isRequestedJobsLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('ProviderJobRequestProvider: fetchRequestedJobs - Started loading requested jobs, page: $_requestedJobsPage');

    try {
      final response = await _repository.fetchRequestedJobs(page: _requestedJobsPage);
      if (refresh) {
        _requestedJobs = response.data;
      } else {
        _requestedJobs.addAll(response.data);
      }
      _hasMoreRequestedJobs = response.hasNextPage;
      _requestedJobsPage++;
      debugPrint('ProviderJobRequestProvider: fetchRequestedJobs - Successfully fetched ${response.data.length} requested jobs. Total: ${_requestedJobs.length}');
    } catch (e) {
      _error = e.toString();
      debugPrint('ProviderJobRequestProvider: fetchRequestedJobs - Error: $_error');
    } finally {
      _isRequestedJobsLoading = false;
      notifyListeners();
      debugPrint('ProviderJobRequestProvider: fetchRequestedJobs - Finished loading requested jobs, notifying listeners.');
    }
  }

  Future<void> fetchSelectedJobs({bool refresh = false}) async {
    if (refresh) {
      _selectedJobsPage = 1;
      _selectedJobs = [];
      _hasMoreSelectedJobs = true;
    }

    if (!refresh && (!_hasMoreSelectedJobs || _isSelectedJobsLoading)) return;

    _isSelectedJobsLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('ProviderJobRequestProvider: fetchSelectedJobs - Started loading selected jobs, page: $_selectedJobsPage');

    try {
      final response = await _repository.fetchSelectedJobs(page: _selectedJobsPage);
      if (refresh) {
        _selectedJobs = response.data;
      } else {
        _selectedJobs.addAll(response.data);
      }
      _hasMoreSelectedJobs = response.hasNextPage;
      _selectedJobsPage++;
      debugPrint('ProviderJobRequestProvider: fetchSelectedJobs - Successfully fetched ${response.data.length} selected jobs. Total: ${_selectedJobs.length}');
    } catch (e) {
      _error = e.toString();
      debugPrint('ProviderJobRequestProvider: fetchSelectedJobs - Error: $_error');
    } finally {
      _isSelectedJobsLoading = false;
      notifyListeners();
      debugPrint('ProviderJobRequestProvider: fetchSelectedJobs - Finished loading selected jobs, notifying listeners.');
    }
  }

  Future<bool> expressInterest(int jobId) async {
    try {
      await _repository.expressInterest(jobId);
      // Refresh the requested jobs list to update the status
      await fetchRequestedJobs(refresh: true);
      return true; // Indicate success
    } catch (e) {
      _error = e.toString();
      debugPrint('ProviderJobRequestProvider: expressInterest - Error: $_error');
      notifyListeners();
      return false; // Indicate failure
    }
  }

  Future<bool> markJobAsProviderDone(int jobId) async {
    _isSelectedJobsLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('ProviderJobRequestProvider: markJobAsProviderDone - Attempting to mark job $jobId as done.');
    try {
      await _repository.providerMarkDone(jobId);
      debugPrint('ProviderJobRequestProvider: markJobAsProviderDone - Successfully marked job $jobId as done. Refreshing selected jobs.');
      // Refresh the selected jobs list to update the status
      await fetchSelectedJobs(refresh: true);
      debugPrint('ProviderJobRequestProvider: markJobAsProviderDone - Selected jobs refreshed after marking job $jobId done.');
      return true; // Indicate success
    } catch (e) {
      _error = e.toString();
      debugPrint('ProviderJobRequestProvider: markJobAsProviderDone - Error: $_error');
      notifyListeners();
      return false; // Indicate failure
    } finally {
      _isSelectedJobsLoading = false;
      notifyListeners();
      debugPrint('ProviderJobRequestProvider: markJobAsProviderDone - Finished operation for job $jobId, notifying listeners.');
    }
  }
} 
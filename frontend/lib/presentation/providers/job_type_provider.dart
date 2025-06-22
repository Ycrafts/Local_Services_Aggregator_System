import 'package:flutter/foundation.dart';
import '../../domain/repositories/job_type_repository.dart';
import '../../domain/models/job_type.dart';

class JobTypeProvider with ChangeNotifier {
  final JobTypeRepository _jobTypeRepository;
  List<JobType> _jobTypes = [];
  List<JobType> _filteredJobTypes = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);
  
  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  JobTypeProvider(this._jobTypeRepository);

  List<JobType> get jobTypes => _filteredJobTypes.isEmpty ? _jobTypes : _filteredJobTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;

  void searchJobTypes(String query) {
    if (query.isEmpty) {
      _filteredJobTypes = [];
    } else {
      _filteredJobTypes = _jobTypes
          .where((jobType) =>
              jobType.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<void> fetchJobTypes({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _jobTypes.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    try {
      final result = await _jobTypeRepository.fetchJobTypes(page: _currentPage);
      _jobTypes = result.jobTypes;
      _hasMorePages = result.hasMorePages;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreJobTypes() async {
    if (!_hasMorePages || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _jobTypeRepository.fetchJobTypes(page: _currentPage + 1);
      _jobTypes.addAll(result.jobTypes);
      _hasMorePages = result.hasMorePages;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _lastFetchTime = null;
    _jobTypes = [];
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
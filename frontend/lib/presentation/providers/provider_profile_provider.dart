import 'package:flutter/foundation.dart';
import '../../domain/repositories/provider_profile_repository.dart';
import '../../domain/models/provider_profile.dart';
import 'job_type_provider.dart';

class ProviderProfileProvider with ChangeNotifier {
  final ProviderProfileRepository _repository;
  bool _isLoading = false;
  String? _error;
  ProviderProfile? _profile;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);
  JobTypeProvider? _jobTypeProvider;

  ProviderProfileProvider(this._repository) {
    fetchProviderProfile(); // Fetch profile on initialization
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProviderProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  void setJobTypeProvider(JobTypeProvider jobTypeProvider) {
    _jobTypeProvider = jobTypeProvider;
    notifyListeners();
  }

  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<bool> fetchProviderProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _profile != null) {
      debugPrint('ProviderProfileProvider: fetchProviderProfile - Returning from cache.');
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('ProviderProfileProvider: fetchProviderProfile - Started loading profile.');

    try {
      _profile = await _repository.getProviderProfile();
      _lastFetchTime = DateTime.now();
      debugPrint('ProviderProfileProvider: fetchProviderProfile - Successfully fetched profile.');
      return _profile != null;
    } catch (e) {
      _error = e.toString();
      debugPrint('ProviderProfileProvider: fetchProviderProfile - Error: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('ProviderProfileProvider: fetchProviderProfile - Finished loading profile, notifying listeners.');
    }
  }

  Future<bool> createProviderProfile({
    String? bio,
    required String address,
    required List<int> jobTypeIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createProviderProfile(
        bio: bio,
        address: address,
        jobTypeIds: jobTypeIds,
      );
      await fetchProviderProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('ProviderProfileProvider: createProviderProfile - Error: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProviderProfile({
    String? bio,
    required String address,
    List<int>? jobTypeIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProviderProfile(
        bio: bio,
        address: address,
        jobTypeIds: jobTypeIds,
      );
      await fetchProviderProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('ProviderProfileProvider: updateProviderProfile - Error: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
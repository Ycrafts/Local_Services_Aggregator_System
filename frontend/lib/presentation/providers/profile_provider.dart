import 'package:flutter/foundation.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/models/customer_profile.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _profileRepository;
  bool _isLoading = false;
  String? _error;
  CustomerProfile? _profile;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  ProfileProvider(this._profileRepository);

  bool get isLoading => _isLoading;
  String? get error => _error;
  CustomerProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<bool> checkProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _profile != null) {
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getCustomerProfile();
      _lastFetchTime = DateTime.now();
      return _profile != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomerProfile({
    required String address,
    required String additionalInfo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileRepository.createCustomerProfile(
        address: address,
        additionalInfo: additionalInfo,
      );
      await checkProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomerProfile({
    required String address,
    required String additionalInfo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileRepository.updateCustomerProfile(
        address: address,
        additionalInfo: additionalInfo,
      );
      await checkProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _lastFetchTime = null;
    _profile = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
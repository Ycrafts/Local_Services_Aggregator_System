import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'notification_provider.dart';
import 'profile_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  User? _user;
  bool _isLoading = false;
  String? _error;
  ProfileProvider? _profileProvider;
  NotificationProvider? _notificationProvider;

  AuthProvider(this._authRepository) {
    _user = _authRepository.getCurrentUser();
  }

  void setProfileProvider(ProfileProvider provider) {
    _profileProvider = provider;
  }

  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isProvider => _user?.isProvider ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<bool> login(String phoneNumber, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authRepository.login(phoneNumber, password);
      // Clear profile cache when logging in
      _profileProvider?.clearCache();
      // Fetch notifications for the new user
      await _notificationProvider?.refreshNotifications();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.logout();
      _user = null;
      // Clear profile cache when logging out
      _profileProvider?.clearCache();
      _notificationProvider?.clearAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
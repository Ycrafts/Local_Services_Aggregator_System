import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../../core/network/api_client.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthRepository(this._apiClient, this._prefs);

  Future<User> login(String phoneNumber, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        data: {
          'phone_number': phoneNumber,
          'password': password,
        },
      );

      print('Login API response data:');
      print(response.data);
      print('Token from response: ${response.data['token']}');

      final user = User.fromJson(response.data['user']);
      await _prefs.setString('token', response.data['token']);
      await _prefs.setString('user', json.encode(user.toJson()));
      return user;
    } catch (e) {
      if (e.toString().contains('Exception: ')) {
        final errorData = json.decode(e.toString().split('Exception: ')[1]);
        if (errorData['message'] == 'Invalid credentials') {
          throw Exception('Invalid phone number or password');
        }
        throw Exception(errorData['message'] ?? 'Invalid phone number or password');
      }
      throw Exception('Invalid phone number or password');
    }
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      print('Registration request data:');
      print({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      });

      final response = await _apiClient.post(
        ApiConfig.register,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        },
      );

      print('Registration response:');
      print(response.data);

      if (response.data['message'] != 'Successfully Registered') {
        throw Exception('Registration failed');
      }

      return User.fromJson(response.data['user']);
    } catch (e) {
      print('Registration error:');
      print(e.toString());
      if (e is DioException && e.response?.statusCode == 422) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          final errorMessages = errors.values
              .expand((e) => e is List ? e : [e])
              .join('\n');
          throw Exception(errorMessages);
        }
      }
      if (e.toString().contains('Exception: ')) {
        final errorData = json.decode(e.toString().split('Exception: ')[1]);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
      throw Exception('Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConfig.logout);
      await _prefs.remove('token');
      await _prefs.remove('user');
    } catch (e) {
      rethrow;
    }
  }

  User? getCurrentUser() {
    final userJson = _prefs.getString('user');
    final token = _prefs.getString('token');

    print('AuthRepository.getCurrentUser() called');
    print('Retrieved user JSON from prefs: $userJson');
    print('Retrieved token from prefs: $token');

    if (userJson == null) {
      print('User JSON is null. User not considered logged in.');
      return null;
    }
    try {
      final Map<String, dynamic> userMap = json.decode(userJson);
      final user = User.fromJson(userMap);
      print('User data successfully parsed from prefs: ${user.toJson()}');
      return user;
    } catch (e) {
      print('Error parsing user data from prefs: $e');
      return null;
    }
  }

  bool get isLoggedIn => _prefs.getString('token') != null;
} 
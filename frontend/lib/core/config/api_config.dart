class ApiConfig {
  static const String baseUrl = 'http://192.168.100.41:8000/api'; // For Android emulator
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // Profile Endpoints
  static const String customerProfile = '/customer-profile';
  static const String providerProfile = '/provider-profile';
  
  // Job Endpoints
  static const String jobs = '/jobs';
  static const String jobTypes = '/job-types';
  static const String expressInterest = '/jobs/{jobId}/express-interest';
  static const String interestedProviders = '/jobs/{jobId}/interested-providers';
  static const String selectProvider = '/jobs/{jobId}/select-provider';
  static const String cancelJob = '/jobs/{jobId}/cancel';
  static const String rateProvider = '/jobs/{jobId}/rate-provider';
  static const String providerDone = '/jobs/{jobId}/provider-done';
  static const String completeJob = '/jobs/{jobId}/complete';
  
  // Provider Specific Endpoints
  static const String requestedJobs = '/requested-jobs';
  static const String selectedJobs = '/selected-jobs';
  
  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/{id}/read';
} 
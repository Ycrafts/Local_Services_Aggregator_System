import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/api_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/job_type_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/repositories/provider_job_request_repository.dart';
import 'domain/repositories/provider_profile_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/job_type_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/provider_job_request_provider.dart';
import 'presentation/providers/provider_profile_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/customer_home_screen.dart';
import 'presentation/screens/home/provider_home_screen.dart';
import 'presentation/screens/notifications/notification_screen.dart';
import 'presentation/screens/profile/customer_profile_setup_screen.dart';
import 'presentation/providers/job_provider.dart';
import 'domain/repositories/job_repository.dart';
import 'package:dio/dio.dart';
import 'presentation/screens/profile/provider_profile_screen.dart';

void main() async {
  print('App startup: main() started');
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  print('App startup: SharedPreferences instance obtained');
  final apiClient = ApiClient(prefs);
  final dio = Dio();
  final jobRepository = JobRepository(apiClient, dio);
  final authRepository = AuthRepository(apiClient, prefs);
  final jobTypeRepository = JobTypeRepository(apiClient);
  final notificationRepository = NotificationRepository(apiClient);
  final profileRepository = ProfileRepository(apiClient);
  final providerJobRequestRepository = ProviderJobRequestRepository(apiClient);
  final providerProfileRepository = ProviderProfileRepository(apiClient);

  runApp(MyApp(
    prefs: prefs,
    authRepository: authRepository,
    jobTypeRepository: jobTypeRepository,
    notificationRepository: notificationRepository,
    profileRepository: profileRepository,
    apiClient: apiClient,
    jobRepository: jobRepository,
    providerJobRequestRepository: providerJobRequestRepository,
    providerProfileRepository: providerProfileRepository,
  ));
  print('App startup: runApp() called');
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthRepository authRepository;
  final JobTypeRepository jobTypeRepository;
  final NotificationRepository notificationRepository;
  final ProfileRepository profileRepository;
  final ApiClient apiClient;
  final JobRepository jobRepository;
  final ProviderJobRequestRepository providerJobRequestRepository;
  final ProviderProfileRepository providerProfileRepository;

  const MyApp({
    super.key,
    required this.prefs,
    required this.authRepository,
    required this.jobTypeRepository,
    required this.notificationRepository,
    required this.profileRepository,
    required this.apiClient,
    required this.jobRepository,
    required this.providerJobRequestRepository,
    required this.providerProfileRepository,
  });

  @override
  Widget build(BuildContext context) {
    print('MyApp: Building MultiProvider...');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            print('AuthProvider created');
            return AuthProvider(authRepository);
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            print('JobTypeProvider created');
            return JobTypeProvider(jobTypeRepository);
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            print('NotificationProvider created');
            return NotificationProvider(notificationRepository);
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print('ProfileProvider created');
            final profileProvider = ProfileProvider(profileRepository);
            // Connect ProfileProvider to AuthProvider
            context.read<AuthProvider>().setProfileProvider(profileProvider);
            return profileProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ProviderJobRequestProvider(providerJobRequestRepository),
        ),
        ChangeNotifierProvider(
          create: (context) {
            print('ProviderProfileProvider created');
            final providerProfileProvider = ProviderProfileProvider(providerProfileRepository);
            // It might be useful to connect this to AuthProvider or JobTypeProvider if logic dictates
            // For example, if profile depends on job types: providerProfileProvider.setJobTypeProvider(context.read<JobTypeProvider>());
            return providerProfileProvider;
          },
        ),
        Provider<ApiClient>(
          create: (context) {
            print('ApiClient provided');
            return apiClient;
          },
        ),
        Provider<JobRepository>(
          create: (context) {
            print('JobRepository provided');
            return jobRepository;
          },
        ),
        ChangeNotifierProvider<JobProvider>(
          create: (context) {
            print('JobProvider created, reading JobRepository...');
            return JobProvider(context.read<JobRepository>());
          },
        ),
      ],
      child: MaterialApp(
        title: 'Local Services Aggregator',
        theme: AppTheme.lightTheme,
        initialRoute: authRepository.isLoggedIn
            ? (authRepository.getCurrentUser()?.role == 'provider'
                ? AppRoutes.providerHome
                : AppRoutes.customerHome)
            : AppRoutes.login,
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.customerHome: (context) => const CustomerHomeScreen(),
          AppRoutes.providerHome: (context) => const ProviderHomeScreen(),
          AppRoutes.notification: (context) => const NotificationScreen(),
          AppRoutes.customerProfileSetup: (context) => const CustomerProfileSetupScreen(),
          AppRoutes.providerProfile: (context) => const ProviderProfileScreen(),
        },
      ),
    );
  }
}

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String customerHome = '/customer-home';
  static const String providerHome = '/provider-home';
  static const String notification = '/notifications';
  static const String customerProfileSetup = '/customer-profile-setup';
  static const String providerProfile = '/provider-profile';
}

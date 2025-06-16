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
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/job_type_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/provider_job_request_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/customer_home_screen.dart';
import 'presentation/screens/home/provider_home_screen.dart';
import 'presentation/screens/notifications/notification_screen.dart';
import 'presentation/screens/profile/customer_profile_setup_screen.dart';
import 'presentation/providers/job_provider.dart';
import 'domain/repositories/job_repository.dart';
import 'package:dio/dio.dart';

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

  runApp(MyApp(
    prefs: prefs,
    authRepository: authRepository,
    jobTypeRepository: jobTypeRepository,
    notificationRepository: notificationRepository,
    profileRepository: profileRepository,
    apiClient: apiClient,
    jobRepository: jobRepository,
    providerJobRequestRepository: providerJobRequestRepository,
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
        ChangeNotifierProvider(
          create: (_) => ProviderJobRequestProvider(providerJobRequestRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Local Services',
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (authProvider.isLoggedIn) {
              return authProvider.isProvider
                  ? const ProviderHomeScreen()
                  : const CustomerHomeScreen();
            }

            return const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/customer-home': (context) => const CustomerHomeScreen(),
          '/provider-home': (context) => const ProviderHomeScreen(),
          '/notifications': (context) => const NotificationScreen(),
          '/customer-profile-setup': (context) => const CustomerProfileSetupScreen(),
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_type_provider.dart';
import '../../providers/notification_provider.dart';
import '../../../domain/models/job_type.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/skeleton_loading.dart';
import '../profile/customer_profile_setup_screen.dart';
import '../profile/customer_profile_screen.dart';
import '../jobs/add_job_screen.dart';
import '../jobs/jobs_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0; // Home tab is selected
  bool _isCheckingProfile = true;

  @override
  void initState() {
    super.initState();
    _checkProfile();
    // Fetch job types when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobTypeProvider>().fetchJobTypes();
    });
  }

  Future<void> _checkProfile() async {
    final profileProvider = context.read<ProfileProvider>();
    final hasProfile = await profileProvider.checkProfile();
    
    if (mounted) {
      setState(() {
        _isCheckingProfile = false;
      });

      if (!hasProfile) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerProfileSetupScreen(),
          ),
        );
      }
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const JobsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.2, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CustomerProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.2, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final authProvider = context.watch<AuthProvider>();
    final jobTypeProvider = context.watch<JobTypeProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final user = authProvider.user;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double popularServiceCardWidth = (screenWidth - (20.0 * 2) - 15.0) / 2;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
      appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
            Stack(
              children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textColor),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
                ),
                if (notificationProvider.unreadNotificationsCount > 0)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${notificationProvider.unreadNotificationsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'What are you looking for?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                        onChanged: (value) {
                          context.read<JobTypeProvider>().searchJobTypes(value);
                        },
                      decoration: InputDecoration(
                        hintText: 'Search Services',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textLightColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Services',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              jobTypeProvider.isLoading && jobTypeProvider.jobTypes.isEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: 4, // Show 4 skeleton cards
                      itemBuilder: (context, index) {
                        return SkeletonCard(
                          width: popularServiceCardWidth,
                          height: 200,
                        );
                      },
                    )
                  : jobTypeProvider.error != null
                      ? Center(child: Text('Error: ${jobTypeProvider.error}'))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: jobTypeProvider.jobTypes.length,
                                itemBuilder: (context, index) {
                                  final jobType = jobTypeProvider.jobTypes[index];
                                  // Determine icon color based on job type name for now
                                  Color iconColor;
                                  switch (jobType.name.toLowerCase()) {
                                    case 'electrician':
                                      iconColor = AppTheme.electricianPrimaryColor;
                                      break;
                                    case 'cleaner':
                                      iconColor = AppTheme.cleanerPrimaryColor;
                                      break;
                                    case 'plumber':
                                      iconColor = AppTheme.plumberPrimaryColor;
                                      break;
                                    case 'house cleaner':
                                      iconColor = AppTheme.housekeeperPrimaryColor;
                                      break;
                                    case 'painter':
                                      iconColor = AppTheme.paintingPrimaryColor;
                                      break;
                                    default:
                                      iconColor = AppTheme.primaryColor;
                                  }

                                  return _buildServiceCard(
                                    title: jobType.name,
                                    price: jobType.baselinePrice,
                                    imagePath: 'assets/images/default_service.png',
                                    iconColor: iconColor,
                                    jobType: jobType,
                                  );
                                },
                              ),
                              if (jobTypeProvider.hasMorePages)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: jobTypeProvider.isLoadingMore
                                      ? const CircularProgressIndicator()
                                      : TextButton(
                                          onPressed: () => jobTypeProvider.loadMoreJobTypes(),
                                          child: const Text('Load More'),
                                        ),
                                ),
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textLightColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work, size: 28),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined, size: 28),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String price,
    required String imagePath,
    required Color iconColor,
    required JobType jobType,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddJobScreen(
              preSelectedJobType: jobType,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Center(
                    child: Icon(
                      _getJobTypeIcon(jobType.name),
                      size: 40,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Starting from ETB ${price}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textLightColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getJobTypeIcon(String jobTypeName) {
    switch (jobTypeName.toLowerCase()) {
      case 'electrician':
        return Icons.electric_bolt;
      case 'cleaner':
        return Icons.cleaning_services;
      case 'plumber':
        return Icons.plumbing;
      case 'house cleaner':
        return Icons.home_repair_service;
      case 'painter':
        return Icons.format_paint;
      default:
        return Icons.work;
    }
  }
}
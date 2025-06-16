import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/job_provider.dart';
import '../../../domain/models/job.dart';
import '../../../domain/models/job_status.dart';
import '../home/customer_home_screen.dart';
import '../profile/customer_profile_screen.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // Jobs tab is selected
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Fetch jobs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CustomerHomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-0.2, 0.0);
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
    final jobProvider = context.watch<JobProvider>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Jobs'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
              onPressed: () {
                context.read<JobProvider>().fetchJobs(forceRefresh: true);
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Open'),
              Tab(text: 'In Progress'),
              Tab(text: 'Provider Done'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: jobProvider.isLoading && jobProvider.jobs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : jobProvider.error != null
                ? Center(child: Text('Error: ${jobProvider.error}'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildJobList(jobProvider, JobStatus.open),
                      _buildJobList(jobProvider, JobStatus.inProgress),
                      _buildJobList(jobProvider, JobStatus.providerDone),
                      _buildJobList(jobProvider, JobStatus.completed),
                      _buildJobList(jobProvider, JobStatus.cancelled),
                    ],
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

  Widget _buildJobList(JobProvider jobProvider, JobStatus status) {
    final jobs = jobProvider.getJobsByStatus(status);

    if (jobs.isEmpty) {
      return Center(
        child: Text(
          'No ${status.displayName.toLowerCase()} jobs',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textLightColor,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length + (jobProvider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == jobs.length) {
          if (jobProvider.isLoadingMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          // Load more when reaching the end
          jobProvider.loadMoreJobs();
          return const SizedBox.shrink();
        }

        final job = jobs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              job.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  job.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 16,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.jobType.name,
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const SizedBox(width: 4),
                    Text(
                      'ETB ${job.proposedPrice}',
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsScreen(job: job),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 
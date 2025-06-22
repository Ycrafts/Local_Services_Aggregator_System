import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/provider_job_request.dart';
import '../../../domain/models/job_status.dart';
import '../../../domain/models/job.dart';
import '../../../domain/models/job_type.dart';
import '../../../presentation/providers/provider_job_request_provider.dart';
import 'provider_job_details_screen.dart';

class ProviderRequestedJobsScreen extends StatefulWidget {
  const ProviderRequestedJobsScreen({super.key});

  @override
  State<ProviderRequestedJobsScreen> createState() => _ProviderRequestedJobsScreenState();
}

class _ProviderRequestedJobsScreenState extends State<ProviderRequestedJobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    debugPrint('ProviderRequestedJobsScreen: initState called');
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderJobRequestProvider>().fetchRequestedJobs(refresh: true);
      context.read<ProviderJobRequestProvider>().fetchSelectedJobs(refresh: true);
    });
  }

  @override
  void dispose() {
    debugPrint('ProviderRequestedJobsScreen: dispose called');
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildJobCard(ProviderJobRequest jobRequest) {
    debugPrint('ProviderRequestedJobsScreen: Building job card for job ${jobRequest.job.id}');
    final job = jobRequest.job;

    return GestureDetector(
      onTap: () async {
        debugPrint('ProviderRequestedJobsScreen: Tapped job card - Navigating to details.');
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProviderJobDetailsScreen(jobRequest: jobRequest),
          ),
        );
        // This code runs when returning from ProviderJobDetailsScreen
        // Refresh both requested and selected jobs lists to ensure updated status/data.
        if (mounted) {
          debugPrint('ProviderRequestedJobsScreen: Returned from job details. Refreshing data.');
          context.read<ProviderJobRequestProvider>().fetchRequestedJobs(refresh: true);
          context.read<ProviderJobRequestProvider>().fetchSelectedJobs(refresh: true);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(job.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ETB ${job.proposedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              if (jobRequest.isInterested && !jobRequest.isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Interest Expressed',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(
                  color: AppTheme.textLightColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Job Type: ${job.jobType.name}',
                style: const TextStyle(
                  color: AppTheme.textLightColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (job.status == JobStatus.completed && job.rating != null && jobRequest.isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Rating: ${job.rating!.rating.toStringAsFixed(1)}/5',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.open:
        return Colors.blue;
      case JobStatus.inProgress:
        return Colors.orange;
      case JobStatus.providerDone:
        return Colors.purple;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderJobRequestProvider>(
      builder: (context, provider, child) {
        debugPrint('ProviderRequestedJobsScreen: Building screen. Loading: ${provider.isLoading}, Error: ${provider.error}');
        debugPrint('ProviderRequestedJobsScreen: Requested jobs count: ${provider.requestedJobs.length}, Selected jobs count: ${provider.selectedJobs.length}');
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Jobs'),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.work_outline),
                  text: 'Requested Jobs',
                ),
                Tab(
                  icon: Icon(Icons.check_circle_outline),
                  text: 'Selected Jobs',
                ),
              ],
            ),
          ),
          body: (provider.isRequestedJobsLoading && provider.requestedJobs.isEmpty && !provider.hasMoreRequestedJobs) || (provider.isSelectedJobsLoading && provider.selectedJobs.isEmpty && !provider.hasMoreSelectedJobs)
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null && provider.requestedJobs.isEmpty && provider.selectedJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.error!,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Requested Jobs Tab
                        RefreshIndicator(
                          onRefresh: () => provider.fetchRequestedJobs(refresh: true),
                          child: provider.requestedJobs.isEmpty && !provider.isRequestedJobsLoading
                              ? const Center(
                                  child: Text(
                                    'No requested jobs yet',
                                    style: TextStyle(
                                      color: AppTheme.textLightColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: provider.requestedJobs.length + (provider.hasMoreRequestedJobs ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == provider.requestedJobs.length) {
                                      // Load more indicator
                                      provider.fetchRequestedJobs();
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    debugPrint('ProviderRequestedJobsScreen: Building requested job item at index $index');
                                    return _buildJobCard(provider.requestedJobs[index]);
                                  },
                                ),
                        ),
                        // Selected Jobs Tab
                        RefreshIndicator(
                          onRefresh: () => provider.fetchSelectedJobs(refresh: true),
                          child: provider.selectedJobs.isEmpty && !provider.isSelectedJobsLoading
                              ? const Center(
                                  child: Text(
                                    'No selected jobs yet',
                                    style: TextStyle(
                                      color: AppTheme.textLightColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: provider.selectedJobs.length + (provider.hasMoreSelectedJobs ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == provider.selectedJobs.length) {
                                      // Load more indicator
                                      provider.fetchSelectedJobs();
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    debugPrint('ProviderRequestedJobsScreen: Building selected job item at index $index');
                                    return _buildJobCard(provider.selectedJobs[index]);
                                  },
                                ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
} 
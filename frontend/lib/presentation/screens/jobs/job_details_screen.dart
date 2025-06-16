import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/job.dart';
import '../../../domain/models/job_status.dart';
import '../../providers/job_provider.dart';
import 'interested_providers_screen.dart';
import 'rate_provider_screen.dart';
import '../home/customer_home_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Job job = widget.job;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Job Information Card
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
              child: Padding(
                      padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                          const SizedBox(height: 12),
                    Text(
                      job.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                          const SizedBox(height: 20),
                          Divider(height: 1, color: AppTheme.textLightColor.withOpacity(0.3)),
                          const SizedBox(height: 20),
                          _buildInfoRow(context, Icons.work_outline, job.jobType.name, 'Job Type'),
                          const SizedBox(height: 12),
                          _buildInfoRow(context, null, 'ETB ${job.proposedPrice}', 'Proposed Price'),
                          const SizedBox(height: 12),
                          _buildInfoRow(context, Icons.calendar_today, 'Posted on ${job.createdAt.toString().split(' ')[0]}', 'Posted Date'),
                          const SizedBox(height: 12),
                          _buildInfoRow(context, Icons.info_outline, job.status.displayName, 'Status'),
                        ],
                      ),
                    ),
                  ),

                  // Assigned Provider Card (if applicable)
                  if (job.assignedProvider != null) ...[
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                              'Assigned Provider',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                        ),
                            const SizedBox(height: 12),
                            _buildInfoRow(context, Icons.person_outline,
                                '${job.assignedProvider!.firstName} ${job.assignedProvider!.lastName}', 'Name'),
                            const SizedBox(height: 12),
                            _buildInfoRow(context, Icons.phone,
                                job.assignedProvider!.phoneNumber, 'Phone'),
                      ],
                    ),
                ),
              ),
                  ],

                  // Action Buttons
                  _buildActionButton(context, job),
                ],
              ),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(BuildContext context, IconData? icon, String value, String label) {
    return Row(
      children: [
        if (icon != null) Icon(icon, size: 20, color: AppTheme.textLightColor),
        const SizedBox(width: 12),
        Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textLightColor),
                            ),
              const SizedBox(height: 4),
                      Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
      ],
    );
  }

  // Helper method to build action buttons based on job status
  Widget _buildActionButton(BuildContext context, Job job) {
    final JobProvider jobProvider = context.read<JobProvider>();

    if (job.status == JobStatus.open) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InterestedProvidersScreen(jobId: job.id),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'View Interested Providers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      );
    } else if (job.status == JobStatus.providerDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () async {
            try {
              final updatedJob = await context.read<JobProvider>().confirmJobCompletion(job.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job marked as completed successfully!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(job: updatedJob),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error confirming completion: ${e.toString()}'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppTheme.successColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Confirm Completion',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      );
    } else if (job.status == JobStatus.completed && job.assignedProvider != null && !job.hasRating) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RateProviderScreen(
                  jobId: job.id,
                  providerProfileId: job.assignedProvider!.id,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppTheme.accentColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Rate Provider',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      );
    } else if (job.status != JobStatus.completed && job.status != JobStatus.cancelled) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Job'),
                content: const Text('Are you sure you want to cancel this job?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      jobProvider.cancelJob(job.id);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            foregroundColor: AppTheme.errorColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Cancel Job',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
} 
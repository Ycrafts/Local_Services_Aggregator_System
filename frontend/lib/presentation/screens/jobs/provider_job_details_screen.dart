import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/provider_job_request.dart';
import '../../../domain/models/job_status.dart';
import '../../../presentation/providers/provider_job_request_provider.dart';

class ProviderJobDetailsScreen extends StatelessWidget {
  final ProviderJobRequest jobRequest;

  const ProviderJobDetailsScreen({super.key, required this.jobRequest});

  @override
  Widget build(BuildContext context) {
    final job = jobRequest.job;
    final customerProfile = job.customerProfile;
    final customerUser = customerProfile?.user;

    final isRequestedJob = job.status == JobStatus.open && !jobRequest.isInterested;
    final isSelectedJob = jobRequest.isSelected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
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
                    const SizedBox(height: 16),
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.description,
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Job Type: ${job.jobType.name}',
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (job.status != JobStatus.cancelled) ...[
              const Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (customerUser != null) ...[
                        _buildDetailRow(Icons.person_outline, 'Name', '${customerUser.firstName} ${customerUser.lastName}'),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.phone, 'Phone', customerUser.phoneNumber),
                        const SizedBox(height: 8),
                      ],
                      if (customerProfile != null) ...[
                        _buildDetailRow(Icons.location_on_outlined, 'Address', customerProfile.address),
                        const SizedBox(height: 8),
                        if (customerProfile.additionalInfo != null && customerProfile.additionalInfo!.isNotEmpty)
                          _buildDetailRow(Icons.info_outline, 'Additional Info', customerProfile.additionalInfo!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (isRequestedJob) // This is for the Express Interest button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isRequestedJob && !jobRequest.isInterested
                      ? () {
                          debugPrint('ProviderJobDetailsScreen: Express interest pressed for job ${job.id}');
                          context.read<ProviderJobRequestProvider>().expressInterest(job.id);
                          Navigator.of(context).pop(); // Go back after expressing interest
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    jobRequest.isInterested ? 'Interest Expressed' : 'Express Interest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (isSelectedJob) ...[
              if (job.status == JobStatus.completed && job.rating != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Your Rating for this Job:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(Icons.star_half, 'Rating', '${job.rating!.rating}/5'),
                        if (job.rating!.comment != null && job.rating!.comment!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildDetailRow(Icons.comment_outlined, 'Comment', job.rating!.comment!),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: job.status == JobStatus.inProgress
                      ? () {
                          debugPrint('ProviderJobDetailsScreen: Provider Mark Done pressed for job ${job.id}');
                          context.read<ProviderJobRequestProvider>().markJobAsProviderDone(job.id);
                          Navigator.of(context).pop(); // Go back after marking done
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    job.status == JobStatus.providerDone ? 'Job Marked Done' : 'Mark Job As Done',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textLightColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
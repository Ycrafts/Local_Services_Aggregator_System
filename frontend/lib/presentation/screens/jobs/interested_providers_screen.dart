import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/job_provider.dart';
import '../../../domain/models/interested_provider.dart';
import '../../../presentation/screens/jobs/job_details_screen.dart';

class InterestedProvidersScreen extends StatefulWidget {
  final int jobId;

  const InterestedProvidersScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<InterestedProvidersScreen> createState() => _InterestedProvidersScreenState();
}

class _InterestedProvidersScreenState extends State<InterestedProvidersScreen> {
  Future<void> _refreshProviders() async {
    await context.read<JobProvider>().fetchInterestedProviders(widget.jobId);
  }

  @override
  void initState() {
    super.initState();
    // Fetch interested providers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProviders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interested Providers'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProviders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProviders,
        child: jobProvider.isLoading && jobProvider.interestedProviders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : jobProvider.error != null
              ? Center(child: Text('Error: ${jobProvider.error}'))
              : jobProvider.interestedProviders.isEmpty
                  ? const Center(
                      child: Text('No providers have expressed interest yet.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobProvider.interestedProviders.length,
                      itemBuilder: (context, index) {
                        final provider = jobProvider.interestedProviders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor,
                                      child: Text(
                                        provider.providerProfile.user.firstName[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${provider.providerProfile.user.firstName} ${provider.providerProfile.user.lastName}',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                provider.providerProfile.rating,
                                                style: TextStyle(
                                                  color: AppTheme.textLightColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bio',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(provider.providerProfile.bio),
                                const SizedBox(height: 12),
                                Text(
                                  'Address',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(provider.providerProfile.address),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Provider Contact'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Phone Number:',
                                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    InkWell(
                                                      onTap: () {
                                                        Clipboard.setData(ClipboardData(
                                                          text: provider.providerProfile.user.phoneNumber,
                                                        ));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Phone number copied to clipboard'),
                                                            backgroundColor: AppTheme.successColor,
                                                          ),
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            provider.providerProfile.user.phoneNumber,
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              color: AppTheme.primaryColor,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          const Icon(
                                                            Icons.copy,
                                                            size: 20,
                                                            color: AppTheme.primaryColor,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Email:',
                                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    InkWell(
                                                      onTap: () {
                                                        Clipboard.setData(ClipboardData(
                                                          text: provider.providerProfile.user.email,
                                                        ));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Email copied to clipboard'),
                                                            backgroundColor: AppTheme.successColor,
                                                          ),
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            provider.providerProfile.user.email,
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              color: AppTheme.primaryColor,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          const Icon(
                                                            Icons.copy,
                                                            size: 20,
                                                            color: AppTheme.primaryColor,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Close'),
                                                  ),
                                                ],
                                              ),
                                            );
                                        },
                                        child: const Text('Contact'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        onPressed: () async {
                                          try {
                                            final updatedJob = await context.read<JobProvider>().selectProvider(
                                              widget.jobId,
                                              provider.providerProfile.id,
                                            );
                                            if (mounted) {
                                                // Replace current screen with job details screen
                                                Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => JobDetailsScreen(job: updatedJob),
                                                ),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Provider selected successfully'),
                                                  backgroundColor: AppTheme.successColor,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: ${e.toString()}'),
                                                  backgroundColor: AppTheme.errorColor,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('Select'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      ),
                    ),
    );
  }
} 
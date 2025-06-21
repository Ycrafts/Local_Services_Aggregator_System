import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';

class ProviderNotificationScreen extends StatefulWidget {
  const ProviderNotificationScreen({super.key});

  @override
  State<ProviderNotificationScreen> createState() => _ProviderNotificationScreenState();
}

class _ProviderNotificationScreenState extends State<ProviderNotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAllNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: notificationProvider.refreshNotifications,
        child: notificationProvider.isLoading && notificationProvider.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.error != null
              ? Center(
                  child: Text(
                    'Error: ${notificationProvider.error}',
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                )
              : notificationProvider.notifications.isEmpty
                  ? const Center(
                      child: Text('No notifications yet.'),
                    )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: notificationProvider.notifications.length,
                              itemBuilder: (context, index) {
                                final notification = notificationProvider.notifications[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  elevation: notification.isRead ? 0.5 : 2,
                                  color: notification.isRead ? Colors.grey[50] : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: notification.isRead ? Colors.transparent : AppTheme.primaryColor.withOpacity(0.3),
                                      width: notification.isRead ? 0 : 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 12),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: notification.isRead ? Colors.transparent : AppTheme.accentColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                notification.message,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                                      color: AppTheme.textColor,
                                                    ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment: Alignment.bottomRight,
                                                child: Text(
                                                  '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year} ${notification.timestamp.hour}:${notification.timestamp.minute}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: AppTheme.textLightColor,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (notificationProvider.hasMorePages)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: TextButton(
                                  onPressed: notificationProvider.isLoading
                                      ? null
                                      : notificationProvider.loadMoreNotifications,
                                  child: notificationProvider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Load More',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
      ),
    );
  }
} 
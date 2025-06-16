import 'package:local_services_aggregator_mobile/core/network/api_client.dart';
import 'package:local_services_aggregator_mobile/core/config/api_config.dart';
import 'package:local_services_aggregator_mobile/domain/models/notification.dart';
import 'package:local_services_aggregator_mobile/domain/models/paginated_response.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<PaginatedResponse<Notification>> fetchNotifications({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.notifications}?page=$page',
      );
      return PaginatedResponse.fromJson(
        response.data,
        (json) => Notification.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.post(ApiConfig.markNotificationRead.replaceFirst('{id}', notificationId.toString()));
    } catch (e) {
      rethrow;
    }
  }
} 
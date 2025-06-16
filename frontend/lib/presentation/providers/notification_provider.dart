import 'package:flutter/foundation.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/models/notification.dart';
import '../../domain/models/paginated_response.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _notificationRepository;
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  int _totalUnreadCount = 0;
  bool _isCountingUnread = false;

  NotificationProvider(this._notificationRepository) {
    _fetchNotifications();
    fetchTotalUnreadNotificationsCount();
  }

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  bool get isCountingUnread => _isCountingUnread;

  int get unreadNotificationsCount => _totalUnreadCount;

  Future<void> _fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications = [];
      _hasMorePages = true;
    }

    if (!_hasMorePages || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _notificationRepository.fetchNotifications(page: _currentPage);
      if (refresh) {
        _notifications = response.data;
      } else {
        _notifications.addAll(response.data);
      }
      _hasMorePages = response.hasNextPage;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalUnreadNotificationsCount() async {
    if (_isCountingUnread) return;
    _isCountingUnread = true;
    notifyListeners();

    int count = 0;
    int page = 1;
    bool hasMore = true;

    try {
      while (hasMore) {
        final response = await _notificationRepository.fetchNotifications(page: page);
        count += response.data.where((n) => !n.isRead).length;
        hasMore = response.hasNextPage;
        page++;
      }
      _totalUnreadCount = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching total unread count: $e');
    } finally {
      _isCountingUnread = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    await _fetchNotifications(refresh: true);
    fetchTotalUnreadNotificationsCount();
  }

  Future<void> loadMoreNotifications() async {
    await _fetchNotifications();
  }

  Future<void> markNotificationRead(int notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = Notification(
          id: _notifications[index].id,
          message: _notifications[index].message,
          timestamp: _notifications[index].timestamp,
          isRead: true,
          type: _notifications[index].type,
          jobId: _notifications[index].jobId,
        );
        if (_totalUnreadCount > 0) {
          _totalUnreadCount--;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
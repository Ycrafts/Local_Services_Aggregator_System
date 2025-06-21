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
  DateTime? _lastReadTimestamp;

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
      
      // If we have a last read timestamp, only count notifications newer than that as unread
      if (_lastReadTimestamp != null) {
        final newNotifications = response.data.map((n) {
          final isNewUnread = n.timestamp.isAfter(_lastReadTimestamp!) && !n.isRead;
          return Notification(
            id: n.id,
            message: n.message,
            timestamp: n.timestamp,
            isRead: !isNewUnread,
            type: n.type,
            jobId: n.jobId,
          );
        }).toList();
        
        if (refresh) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }
      } else {
      if (refresh) {
        _notifications = response.data;
      } else {
        _notifications.addAll(response.data);
      }
      }
      
      _hasMorePages = response.hasNextPage;
      _currentPage++;
      
      // Update unread count based on notifications after last read timestamp
      _updateUnreadCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateUnreadCount() {
    if (_lastReadTimestamp != null) {
      _totalUnreadCount = _notifications.where((n) => 
        n.timestamp.isAfter(_lastReadTimestamp!) && !n.isRead
      ).length;
    } else {
      _totalUnreadCount = _notifications.where((n) => !n.isRead).length;
    }
  }

  Future<void> fetchTotalUnreadNotificationsCount() async {
    if (_isCountingUnread) return;
    _isCountingUnread = true;
    notifyListeners();

    try {
      await _fetchNotifications(refresh: true);
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error fetching total unread count: $e');
    } finally {
      _isCountingUnread = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    await _fetchNotifications(refresh: true);
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

  Future<void> markAllNotificationsAsRead() async {
    try {
      // Set the last read timestamp to now
      _lastReadTimestamp = DateTime.now();
      
      // Get all notifications that need to be marked as read
      final notificationsToMark = _notifications.where((n) => 
        n.timestamp.isBefore(_lastReadTimestamp!) && !n.isRead
      ).toList();
      
      // Mark each notification as read
      for (final notification in notificationsToMark) {
        await _notificationRepository.markAsRead(notification.id);
      }

      // Update local state
      _notifications = _notifications.map((n) {
        if (n.timestamp.isBefore(_lastReadTimestamp!)) {
          return Notification(
            id: n.id,
            message: n.message,
            timestamp: n.timestamp,
            isRead: true,
            type: n.type,
            jobId: n.jobId,
          );
        }
        return n;
      }).toList();

      // Update unread count
      _updateUnreadCount();
      
      notifyListeners();
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
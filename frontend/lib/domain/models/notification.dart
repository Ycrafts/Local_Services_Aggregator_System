import 'package:flutter/foundation.dart';

class Notification {
  final int id;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final int? jobId;

  Notification({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.jobId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? '',
      jobId: json['job_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'job_id': jobId,
    };
  }
} 
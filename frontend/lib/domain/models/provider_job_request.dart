import 'job.dart';
import 'job_status.dart';

class ProviderJobRequest {
  final int id;
  final bool isInterested;
  final bool isSelected;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Job job;

  ProviderJobRequest({
    required this.id,
    required this.isInterested,
    required this.isSelected,
    required this.createdAt,
    required this.updatedAt,
    required this.job,
  });

  factory ProviderJobRequest.fromJson(Map<String, dynamic> json) {
    return ProviderJobRequest(
      id: json['id'] as int,
      isInterested: json['is_interested'] as bool,
      isSelected: json['is_selected'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      job: Job.fromJson(json['job'] as Map<String, dynamic>),
    );
  }

  bool get isOpen => job.status == JobStatus.open;
  bool get isInProgress => job.status == JobStatus.inProgress;
  bool get isProviderDone => job.status == JobStatus.providerDone;
  bool get isCompleted => job.status == JobStatus.completed;
  bool get isCancelled => job.status == JobStatus.cancelled;
} 
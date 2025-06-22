enum JobStatus {
  open,
  inProgress,
  providerDone,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case JobStatus.open:
        return 'Open';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.providerDone:
        return 'Provider Done';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return JobStatus.open;
      case 'in_progress':
        return JobStatus.inProgress;
      case 'provider_done':
        return JobStatus.providerDone;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        throw Exception('Invalid job status: $status');
    }
  }
} 
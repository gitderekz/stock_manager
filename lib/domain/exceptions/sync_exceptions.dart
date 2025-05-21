class SyncException implements Exception {
  final String message;
  final int? code;

  SyncException({required this.message, this.code});

  @override
  String toString() => 'SyncException: $message';
}

class SyncConflictException extends SyncException {
  SyncConflictException()
      : super(message: 'Sync conflict detected', code: 409);
}

class OfflineOperationException extends SyncException {
  OfflineOperationException()
      : super(message: 'Operation queued for sync', code: 202);
}
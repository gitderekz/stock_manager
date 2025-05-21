part of 'sync_bloc.dart';

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {
  final int syncedItems;

  SyncSuccess(this.syncedItems);
}

class SyncError extends SyncState {
  final String message;

  SyncError(this.message);
}

class SyncStatus extends SyncState {
  final int pendingCount;

  SyncStatus(this.pendingCount);
}
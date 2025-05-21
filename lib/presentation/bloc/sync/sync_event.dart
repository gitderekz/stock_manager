part of 'sync_bloc.dart';

abstract class SyncEvent {}

class SyncData extends SyncEvent {}

class CheckSyncStatus extends SyncEvent {}
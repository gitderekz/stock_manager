import 'package:stock_manager/domain/entities/sync_queue_item.dart';

abstract class SyncRepository {
  Future<List<SyncQueueItem>> getPendingSyncItems();
  Future<void> addToQueue(SyncQueueItem item);
  Future<void> markAsSynced(int id);
  Future<void> clearSyncedItems();
  Future<int> getPendingSyncCount();
  Future<SyncResult> processSync();
}
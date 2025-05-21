import 'package:stock_manager/domain/entities/sync_queue_item.dart';

import '../../utils/helpers/database_helper.dart';
import '../../utils/services/connectivity_service.dart';

abstract class SyncRepository {
  Future<List<SyncQueueItem>> getPendingSyncItems();
  Future<void> addToQueue(SyncQueueItem item);
  Future<void> markAsSynced(int id);
  Future<void> clearSyncedItems();
  Future<int> getPendingSyncCount();
}
class SyncRepositoryImpl implements SyncRepository {
  final DatabaseHelper databaseHelper;
  final ConnectivityService connectivityService;

  SyncRepositoryImpl({
    required this.databaseHelper,
    required this.connectivityService,
  });

  @override
  Future<void> addToQueue(SyncQueueItem item) {
    // TODO: implement addToQueue
    throw UnimplementedError();
  }

  @override
  Future<void> clearSyncedItems() {
    // TODO: implement clearSyncedItems
    throw UnimplementedError();
  }

  @override
  Future<int> getPendingSyncCount() {
    // TODO: implement getPendingSyncCount
    throw UnimplementedError();
  }

  @override
  Future<List<SyncQueueItem>> getPendingSyncItems() {
    // TODO: implement getPendingSyncItems
    throw UnimplementedError();
  }

  @override
  Future<void> markAsSynced(int id) {
    // TODO: implement markAsSynced
    throw UnimplementedError();
  }
}

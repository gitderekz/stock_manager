import 'package:hive/hive.dart';
import 'package:stock_manager/domain/entities/sync_queue_item.dart';
import 'package:stock_manager/domain/entities/user.dart';

class HiveService {
  static const _userBox = 'user';
  static const _syncQueueBox = 'sync_queue';
  static const _productsBox = 'products';
  static const _inventoryBox = 'inventory';

  static Future<void> init(String path) async {
    Hive.init(path);

    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(SyncQueueItemAdapter());
    // Register other adapters...

    // Open boxes
    await Future.wait([
      Hive.openBox<User>(_userBox),
      Hive.openBox<SyncQueueItem>(_syncQueueBox),
      Hive.openBox(_productsBox),
      Hive.openBox(_inventoryBox),
    ]);
  }

  Future<void> cacheUser(User user) async {
    final box = await Hive.openBox<User>(_userBox);
    await box.put('current_user', user);
  }

  Future<User?> getCachedUser() async {
    final box = await Hive.openBox<User>(_userBox);
    return box.get('current_user');
  }

  Future<void> clearUser() async {
    final box = await Hive.openBox<User>(_userBox);
    await box.clear();
  }

  Future<void> addToSyncQueue(SyncQueueItem item) async {
    final box = await Hive.openBox<SyncQueueItem>(_syncQueueBox);
    await box.add(item);
  }

  Future<List<SyncQueueItem>> getSyncQueue() async {
    final box = await Hive.openBox<SyncQueueItem>(_syncQueueBox);
    return box.values.toList();
  }

  Future<void> clearSyncQueue() async {
    final box = await Hive.openBox<SyncQueueItem>(_syncQueueBox);
    await box.clear();
  }

// Other local storage methods...
}
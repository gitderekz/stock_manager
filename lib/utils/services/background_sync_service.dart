import 'package:stock_manager/utils/services/sync_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:stock_manager/injection_container.dart' as di;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await di.init();
      final syncService = di.sl<SyncService>();
      await syncService.syncData();
      return true;
    } catch (e) {
      return false;
    }
  });
}

class BackgroundSyncService {
  static const String _syncTask = 'stockManagerSync';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      _syncTask,
      _syncTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelSync() async {
    await Workmanager().cancelByTag(_syncTask);
  }
}
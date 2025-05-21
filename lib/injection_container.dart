import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_manager/data/datasources/local/auth_local.dart';
import 'package:stock_manager/data/datasources/local/hive_service.dart';
import 'package:stock_manager/data/datasources/remote/auth_api.dart';
import 'package:stock_manager/data/repositories/auth_repository.dart';
import 'package:stock_manager/data/repositories/product_repository.dart' show ProductRepositoryImpl;
import 'package:stock_manager/data/repositories/inventory_repository.dart' show InventoryRepositoryImpl;
import 'package:stock_manager/data/repositories/sync_repository.dart' as data;
import 'package:stock_manager/utils/services/background_sync_service.dart';
import 'package:stock_manager/utils/services/connectivity_service.dart';
import 'package:stock_manager/utils/services/sync_service.dart';
import 'package:stock_manager/utils/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:stock_manager/utils/helpers/database_helper.dart';

import 'data/datasources/remote/inventory_api.dart';
import 'data/datasources/remote/product_api.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/sync_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await dotenv.load(fileName: '.env');

  // External
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingletonAsync<SharedPreferences>(() => SharedPreferences.getInstance());

  // Initialize Hive
  final appDocDir = await getApplicationDocumentsDirectory();
  await HiveService.init(appDocDir.path);

  // Core Services
  sl.registerSingleton<HiveService>(HiveService());
  sl.registerSingleton<ConnectivityService>(ConnectivityService());
  sl.registerSingleton<NotificationService>(NotificationService());

  // Local DB Helper
  sl.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // APIs
  sl.registerSingleton<AuthApi>(AuthApi(sl()));
  sl.registerSingleton<ProductApi>(ProductApi(sl()));
  sl.registerSingleton<InventoryApi>(InventoryApi(sl()));

  // Local Data Sources
  sl.registerSingleton<AuthLocal>(AuthLocal(
    sharedPreferences: await sl.getAsync<SharedPreferences>(),
    hiveService: sl(),
  ));

  // Repositories
  sl.registerSingleton<ProductRepository>(ProductRepositoryImpl(
    productApi: sl(),
    databaseHelper: sl(),
    connectivityService: sl(),
  ));

  sl.registerSingleton<InventoryRepository>(InventoryRepositoryImpl(
    inventoryApi: sl(),
    databaseHelper: sl(),
  ));

  // sl.registerSingleton<SyncRepository>(data.SyncRepositoryImpl(
  //   databaseHelper: sl(),
  //   connectivityService: sl(),
  // ) as SyncRepository);
  sl.registerSingleton<SyncRepository>(
    data.SyncRepositoryImpl(
      databaseHelper: sl(),
      connectivityService: sl(),
    ) as SyncRepository,
  );


  // Domain Services
  sl.registerSingleton<SyncService>(SyncService(
    connectivityService: sl(),
    syncRepository: sl(),
    productRepository: sl(),
    inventoryRepository: sl(),
  ));

  await sl<NotificationService>().init();
  await BackgroundSyncService.initialize();
}





// import 'package:get_it/get_it.dart';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stock_manager/data/datasources/local/auth_local.dart';
// import 'package:stock_manager/data/datasources/local/hive_service.dart';
// import 'package:stock_manager/data/datasources/remote/auth_api.dart';
// import 'package:stock_manager/data/repositories/auth_repository.dart';
// import 'package:stock_manager/data/repositories/product_repository.dart';
// import 'package:stock_manager/data/repositories/inventory_repository.dart';
// import 'package:stock_manager/data/repositories/sync_repository.dart';
// import 'package:stock_manager/utils/services/background_sync_service.dart';
// import 'package:stock_manager/utils/services/connectivity_service.dart';
// import 'package:stock_manager/utils/services/sync_service.dart';
// import 'package:stock_manager/utils/services/notification_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import 'domain/repositories/inventory_repository.dart';
//
// final sl = GetIt.instance;
//
// Future<void> init() async {
//   // External
//   await dotenv.load(fileName: '.env');
//   sl.registerSingleton<Dio>(Dio());
//   sl.registerSingletonAsync<SharedPreferences>(
//         () => SharedPreferences.getInstance(),
//   );
//
//   // Services
//   sl.registerSingleton<HiveService>(HiveService());
//   sl.registerSingleton<ConnectivityService>(ConnectivityService());
//   sl.registerSingleton<NotificationService>(NotificationService());
//
//   // Data sources
//   sl.registerSingleton<AuthApi>(AuthApi(sl()));
//   sl.registerSingleton<AuthLocal>(AuthLocal(
//     sharedPreferences: sl(),
//     hiveService: sl(),
//   ));
//
//   // Repositories
//   sl.registerSingleton<AuthRepository>(AuthRepository(
//     authApi: sl(),
//     authLocal: sl(),
//     connectivityService: sl(),
//   ));
//
//   sl.registerSingleton<ProductRepository>(ProductRepository(
//     // Initialize with required dependencies
//   ));
//
//   sl.registerSingleton<InventoryRepository>(InventoryRepository(
//     // Initialize with required dependencies
//   ));
//
//   sl.registerSingleton<SyncRepository>(SyncRepository(
//     // Initialize with required dependencies
//   ));
//
//   // Services that depend on repositories
//   sl.registerSingleton<SyncService>(SyncService(
//     connectivityService: sl(),
//     syncRepository: sl(),
//     productRepository: sl(),
//     inventoryRepository: sl(),
//   ));
//
//   // Initialize services
//   await sl<HiveService>().init();
//   await sl<NotificationService>().init();
//   await BackgroundSyncService.initialize();
// }
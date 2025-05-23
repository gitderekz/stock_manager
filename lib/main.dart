import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

import 'package:stock_manager/app/app.dart';
import 'package:stock_manager/app/config/localization.dart';
import 'package:stock_manager/app/config/theme.dart';
import 'package:stock_manager/data/datasources/local/hive_service.dart';
import 'package:stock_manager/data/datasources/remote/auth_api.dart';
import 'package:stock_manager/data/datasources/local/auth_local.dart';
import 'package:stock_manager/data/datasources/remote/product_api.dart';
import 'package:stock_manager/data/repositories/product_repository.dart';
import 'package:stock_manager/presentation/bloc/inventory/stock_movement_bloc.dart';
import 'package:stock_manager/presentation/bloc/notifications/notifications_bloc.dart';
import 'package:stock_manager/presentation/bloc/products/product_list_bloc.dart';
import 'package:stock_manager/presentation/bloc/settings/settings_bloc.dart';
import 'package:stock_manager/presentation/cubits/connectivity_cubit.dart';
import 'package:stock_manager/utils/constants/environment.dart';
import 'package:stock_manager/utils/helpers/database_helper.dart';
import 'package:stock_manager/utils/services/connectivity_service.dart';

import 'package:stock_manager/domain/repositories/auth_repository.dart';
import 'package:stock_manager/data/repositories/auth_repository.dart' as data;

import 'app/config/router.dart';
import 'data/datasources/remote/inventory_api.dart';
import 'data/repositories/inventory_repository.dart' as data_inventory;
import 'domain/entities/user.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: Environment.envFile);

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await HiveService.init(appDocumentDir.path);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: appDocumentDir,
  );

  // Initialize core dependencies
  final dio = Dio();
  final connectivity = Connectivity();

  // Initialize services
  final connectivityService = ConnectivityService(connectivity);
  final databaseHelper = DatabaseHelper.instance;

  // Initialize API clients
  final authApi = AuthApi(dio);
  final productApi = ProductApi(dio);
  final inventoryApi = InventoryApi(dio);

  // Initialize local storage
  final sharedPreferences = await SharedPreferences.getInstance();
  final hiveService = HiveService();
  final authLocal = AuthLocal(
    sharedPreferences: sharedPreferences,
    hiveService: hiveService,
  );

  // Initialize repositories
  final authRepository = data.DataAuthRepository(
    authApi: authApi,
    authLocal: authLocal,
    connectivityService: connectivityService,
  );

  final productRepository = /*data.*/ProductRepositoryImpl(
    productApi: productApi,
    databaseHelper: databaseHelper,
    connectivityService: connectivityService,
  );

  final inventoryRepository = data_inventory.InventoryRepositoryImpl(
    inventoryApi: inventoryApi,
    databaseHelper: databaseHelper,
  );

  // Check authentication status
  final isAuth = await authRepository.isAuthenticated();
  final user = isAuth ? await authRepository.getCachedUser() : null;

  runApp(StockManagerApp(
    authRepository: authRepository,
    productRepository: productRepository,
    inventoryRepository: inventoryRepository,
    connectivityService: connectivityService,
    initialUser: user,
  ));
}

class StockManagerApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final InventoryRepository inventoryRepository;
  final ConnectivityService connectivityService;
  final User? initialUser;

  const StockManagerApp({
    super.key,
    required this.authRepository,
    required this.productRepository,
    required this.inventoryRepository,
    required this.connectivityService,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => HiveService()),
        RepositoryProvider(create: (_) => authRepository),
        RepositoryProvider(create: (_) => productRepository),
        RepositoryProvider(create: (_) => inventoryRepository),
        RepositoryProvider(create: (_) => connectivityService),
        RepositoryProvider(create: (_) => DatabaseHelper.instance),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConnectivityCubit(Connectivity()),
          ),
          BlocProvider(
            create: (_) => AuthBloc(authRepository)
              ..add(initialUser != null
                  ? LoginSuccess(initialUser!)
                  : AppStarted()),
          ),
          BlocProvider(
            create: (context) => ProductListBloc(
              context.read<ProductRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => StockMovementBloc(
              inventoryRepository: context.read<InventoryRepository>(),
              productId: 1,
            ),
          ),
          BlocProvider(
            create: (context) => SettingsBloc(),
          ),
        ],
        child: MaterialApp(
          title: 'Stock Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRouter.generateRoute,
          home: const App(),
        ),
      ),
    );
  }
}
// ************************************



// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:dio/dio.dart';
//
// import 'package:stock_manager/app/app.dart';
// import 'package:stock_manager/app/config/localization.dart';
// import 'package:stock_manager/app/config/theme.dart';
// import 'package:stock_manager/data/datasources/local/hive_service.dart';
// import 'package:stock_manager/data/datasources/remote/auth_api.dart';
// import 'package:stock_manager/data/datasources/local/auth_local.dart';
// import 'package:stock_manager/data/repositories/product_repository.dart';
// import 'package:stock_manager/presentation/bloc/inventory/stock_movement_bloc.dart';
// import 'package:stock_manager/presentation/bloc/notifications/notifications_bloc.dart';
// import 'package:stock_manager/presentation/bloc/products/product_list_bloc.dart';
// import 'package:stock_manager/presentation/bloc/settings/settings_bloc.dart';
// import 'package:stock_manager/presentation/cubits/connectivity_cubit.dart';
// import 'package:stock_manager/utils/constants/environment.dart';
// import 'package:stock_manager/utils/helpers/database_helper.dart';
// import 'package:stock_manager/utils/services/connectivity_service.dart';
//
// import 'package:stock_manager/domain/repositories/auth_repository.dart';
// import 'package:stock_manager/data/repositories/auth_repository.dart' as data;
//
// import 'app/config/router.dart';
// import 'data/datasources/remote/inventory_api.dart';
// import 'data/repositories/inventory_repository.dart';
// import 'domain/entities/user.dart';
// import 'domain/repositories/inventory_repository.dart';
// import 'domain/repositories/product_repository.dart';
// import 'presentation/bloc/auth/auth_bloc.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await dotenv.load(fileName: Environment.envFile);
//
//   final appDocumentDir = await getApplicationDocumentsDirectory();
//   await HiveService.init(appDocumentDir.path);
//
//   HydratedBloc.storage = await HydratedStorage.build(
//     storageDirectory: appDocumentDir,
//   );
//
//   final dio = Dio();
//   final authApi = AuthApi(dio);
//   final sharedPreferences = await SharedPreferences.getInstance();
//   final hiveService = HiveService();
//   final authLocal = AuthLocal(
//     sharedPreferences: sharedPreferences,
//     hiveService: hiveService,
//   );
//   final connectivityService = ConnectivityService();
//
//   final authRepository = data.DataAuthRepository(
//     authApi: authApi,
//     authLocal: authLocal,
//     connectivityService: connectivityService,
//   );
//
//   final isAuth = await authRepository.isAuthenticated();
//   final user = isAuth ? await authRepository.getCachedUser() : null;
//
//   runApp(StockManagerApp(authRepository: authRepository, initialUser: user,));
// }
//
// // class StockManagerApp extends StatelessWidget {
// //   final AuthRepository authRepository;
// //   final User? initialUser;
// //
// //   const StockManagerApp({super.key, required this.authRepository, this.initialUser,});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MultiRepositoryProvider(
// //       providers: [
// //         RepositoryProvider(create: (_) => HiveService()),
// //         RepositoryProvider<AuthRepository>(create: (_) => authRepository),
// //       ],
// //       child: BlocProvider(
// //         create: (_) => AuthBloc(authRepository)
// //           ..add(initialUser != null
// //               ? LoginSuccess(initialUser!) // 👈 auto-login
// //               : AppStarted()), // fallback,
// //         child: MaterialApp(
// //           title: 'Stock Manager',
// //           debugShowCheckedModeBanner: false,
// //           theme: AppTheme.lightTheme,
// //           darkTheme: AppTheme.darkTheme,
// //           themeMode: ThemeMode.system,
// //           localizationsDelegates: AppLocalizations.localizationsDelegates,
// //           supportedLocales: AppLocalizations.supportedLocales,
// //           home: const App(),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // class StockManagerApp extends StatelessWidget {
// //   final AuthRepository authRepository;
// //   final User? initialUser;
// //
// //   const StockManagerApp({super.key, required this.authRepository, this.initialUser});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MultiRepositoryProvider(
// //         providers: [
// //           RepositoryProvider(create: (_) => HiveService()),
// //           RepositoryProvider<AuthRepository>(create: (_) => authRepository),
// //           RepositoryProvider<InventoryRepository>(create: (_) => InventoryRepository()), // Add this if missing
// //         ],
// //         child: MultiBlocProvider(
// //             providers: [
// //                 BlocProvider<ConnectivityCubit>(
// //                 create: (context) => ConnectivityCubit(Connectivity()),
// //               ),
// //               BlocProvider<AuthBloc>(
// //                 create: (_) => AuthBloc(authRepository)
// //                 ..add(initialUser != null
// //                 ? LoginSuccess(initialUser!)
// //                     : AppStarted()),
// //                 BlocProvider<StockMovementBloc>(
// //                   create: (context) => StockMovementBloc(
// //                     inventoryRepository: context.read<InventoryRepository>(),
// //                     productId: 1,
// //                   ),
// //                 ),
// //                 BlocProvider<SettingsBloc>(
// //                   create: (context) => SettingsBloc(),
// //                 ),
// //               )
// //             ],
// //             child: MaterialApp(
// //               title: 'Stock Manager',
// //               debugShowCheckedModeBanner: false,
// //               theme: AppTheme.lightTheme,
// //               darkTheme: AppTheme.darkTheme,
// //               themeMode: ThemeMode.system,
// //               localizationsDelegates: AppLocalizations.localizationsDelegates,
// //               supportedLocales: AppLocalizations.supportedLocales,
// //               onGenerateRoute: AppRouter.generateRoute,
// //               home: const App(),
// //             ),
// //         ),
// //     );
// //   }
// // }
// class StockManagerApp extends StatelessWidget {
//   final AuthRepository authRepository;
//   final User? initialUser;
//
//   const StockManagerApp({super.key, required this.authRepository, this.initialUser});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiRepositoryProvider(
//         providers: [
//           RepositoryProvider(create: (_) => HiveService()),
//           RepositoryProvider<AuthRepository>(create: (_) => authRepository),
//           RepositoryProvider<InventoryRepository>(
//             create: (_) => InventoryRepositoryImpl(
//               inventoryApi: InventoryApi(Dio()), // Add your InventoryApi
//               databaseHelper: DatabaseHelper.instance,   // Add your DatabaseHelper
//             ),
//           ),
//           RepositoryProvider<ProductRepository>(
//             create: (_) => ProductRepositoryImpl(), // Your implementation
//           ),
//         ],
//         child: MultiBlocProvider(
//           providers: [
//             BlocProvider<ConnectivityCubit>(
//               create: (context) => ConnectivityCubit(Connectivity()),
//             ),
//             BlocProvider<AuthBloc>(
//               create: (_) => AuthBloc(authRepository)
//                 ..add(initialUser != null
//                     ? LoginSuccess(initialUser!)
//                     : AppStarted()),
//             ),
//             BlocProvider<ProductListBloc>(
//               create: (context) => ProductListBloc(
//                 context.read<ProductRepository>(), // Make sure this is provided
//               ),
//             ),
//             BlocProvider<StockMovementBloc>(
//               create: (context) => StockMovementBloc(
//                 inventoryRepository: context.read<InventoryRepository>(),
//                 productId: 1,
//               ),
//             ),
//             BlocProvider<SettingsBloc>(
//               create: (context) => SettingsBloc(),
//             ),
//           ],
//
//           child: MaterialApp(
//             title: 'Stock Manager',
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: ThemeMode.system,
//             localizationsDelegates: AppLocalizations.localizationsDelegates,
//             supportedLocales: AppLocalizations.supportedLocales,
//             onGenerateRoute: AppRouter.generateRoute,
//             home: const App(),
//           ),
//       ),
//     );
//   }
// }
// // &*****************************************




// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:stock_manager/app/app.dart';
// import 'package:stock_manager/app/config/localization.dart';
// import 'package:stock_manager/app/config/theme.dart';
// import 'package:stock_manager/data/datasources/local/hive_service.dart';
// import 'package:stock_manager/utils/constants/environment.dart';
// import 'package:stock_manager/utils/services/connectivity_service.dart';
//
// import 'data/datasources/local/auth_local.dart';
// import 'data/datasources/remote/auth_api.dart';
// // import 'data/services/connectivity_service.dart';
// // import 'data/repositories/auth_repository.dart';
// import 'presentation/bloc/auth/auth_bloc.dart';
//
// import 'package:stock_manager/domain/repositories/auth_repository.dart';
// import 'package:stock_manager/data/repositories/auth_repository.dart' as data;
//
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Load environment variables
//   await dotenv.load(fileName: Environment.envFile);
//
//   // Initialize Hive for local storage
//   final appDocumentDir = await getApplicationDocumentsDirectory();
//   await HiveService.init(appDocumentDir.path);
//
//   // Initialize HydratedBloc storage
//   HydratedBloc.storage = await HydratedStorage.build(
//     storageDirectory: appDocumentDir,
//   );
//
//   final sharedPreferences = await SharedPreferences.getInstance();
//   final hiveService = HiveService(); // Already initialized earlier
//   // Instantiate required dependencies
//   final dio = Dio();
//   final authApi = AuthApi(dio); // You can pass a Dio client or baseUrl if needed
//   final authLocal = AuthLocal(
//     sharedPreferences: sharedPreferences,
//     hiveService: hiveService,
//   ); // Usually uses Hive or SharedPreferences
//   final connectivityService = ConnectivityService();
//
//   // Inject dependencies into AuthRepository
//   final authRepository = data.AuthRepository(
//     authApi: authApi,
//     authLocal: authLocal,
//     connectivityService: connectivityService,
//   );
//
//   runApp(StockManagerApp(authRepository: authRepository));
// }
//
// class StockManagerApp extends StatelessWidget {
//   final AuthRepository authRepository;
//
//   const StockManagerApp({super.key, required this.authRepository});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiRepositoryProvider(
//       providers: [
//         RepositoryProvider(create: (_) => HiveService()),
//         RepositoryProvider(create: (_) => authRepository),
//       ],
//       child: BlocProvider(
//         create: (_) => AuthBloc(authRepository),
//         child: MaterialApp(
//           title: 'Stock Manager',
//           debugShowCheckedModeBanner: false,
//           theme: AppTheme.lightTheme,
//           darkTheme: AppTheme.darkTheme,
//           themeMode: ThemeMode.system,
//           localizationsDelegates: AppLocalizations.localizationsDelegates,
//           supportedLocales: AppLocalizations.supportedLocales,
//           home: const App(),
//         ),
//       ),
//     );
//   }
// }
// // ************************************

// class StockManagerApp extends StatelessWidget {
//   const StockManagerApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiRepositoryProvider(
//       providers: [
//         RepositoryProvider(create: (context) => HiveService()),
//       ],
//       child: MaterialApp(
//         title: 'Stock Manager',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: ThemeMode.system,
//         localizationsDelegates: AppLocalizations.localizationsDelegates,
//         supportedLocales: AppLocalizations.supportedLocales,
//         home: const App(),
//       ),
//     );
//   }
// }
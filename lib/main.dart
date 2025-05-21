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
import 'package:stock_manager/utils/constants/environment.dart';
import 'package:stock_manager/utils/services/connectivity_service.dart';

import 'package:stock_manager/domain/repositories/auth_repository.dart';
import 'package:stock_manager/data/repositories/auth_repository.dart' as data;

import 'presentation/bloc/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: Environment.envFile);

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await HiveService.init(appDocumentDir.path);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: appDocumentDir,
  );

  final dio = Dio();
  final authApi = AuthApi(dio);
  final sharedPreferences = await SharedPreferences.getInstance();
  final hiveService = HiveService();
  final authLocal = AuthLocal(
    sharedPreferences: sharedPreferences,
    hiveService: hiveService,
  );
  final connectivityService = ConnectivityService();

  final authRepository = data.DataAuthRepository(
    authApi: authApi,
    authLocal: authLocal,
    connectivityService: connectivityService,
  );

  runApp(StockManagerApp(authRepository: authRepository));
}

class StockManagerApp extends StatelessWidget {
  final AuthRepository authRepository;

  const StockManagerApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => HiveService()),
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authRepository),
        child: MaterialApp(
          title: 'Stock Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const App(),
        ),
      ),
    );
  }
}
// &*****************************************




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
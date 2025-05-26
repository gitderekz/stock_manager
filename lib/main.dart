// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_manager/config/env.dart';
import 'package:stock_manager/controllers/stock_controller.dart';
import 'package:stock_manager/utils/socket_service.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'config/localization.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'utils/database_helper.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init();

  // Initialize shared preferences and database
  final prefs = await SharedPreferences.getInstance();
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  runApp(MyApp(prefs: prefs, dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final DatabaseHelper dbHelper;

  const MyApp({required this.prefs, required this.dbHelper, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SocketService().initialize(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefs)),
        BlocProvider(create: (_) => LanguageCubit(prefs)),
        BlocProvider(create: (_) => AuthCubit(dbHelper)),
        BlocProvider(create: (_) => ProductCubit(dbHelper)),
        BlocProvider(create: (_) => StockCubit(dbHelper)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: 'Stock Management',
                theme: themeState.isDarkMode ? darkTheme : lightTheme,
                initialRoute: '/',
                onGenerateRoute: AppRoutes.generateRoute,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: languageState.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
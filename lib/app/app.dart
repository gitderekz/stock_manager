import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/app/config/router.dart';
import 'package:stock_manager/presentation/screens/auth/login_screen.dart';
import 'package:stock_manager/presentation/cubits/connectivity_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'config/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectivityCubit(Connectivity()),
      child: MaterialApp(
        title: 'Stock Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        home: const LoginScreen(),
      ),
    );
  }
}
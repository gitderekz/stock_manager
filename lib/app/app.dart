import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/app/config/router.dart';
import 'package:stock_manager/presentation/screens/auth/login_screen.dart';
import 'package:stock_manager/presentation/cubits/connectivity_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stock_manager/presentation/bloc/auth/auth_bloc.dart';
import 'package:stock_manager/presentation/screens/main_navigation_screen.dart';

import '../presentation/screens/home/home_screen.dart';
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
        // home: const LoginScreen(),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainNavigationScreen();//HomeScreen(); // Or ProductListScreen if Home not ready
            } else if (state is AuthUnauthenticated) {
              return const LoginScreen();
            } else if (state is AuthLoading) {
              return const LoadingScreen(); // optional loading widget
            } else {
              return const SplashScreen(); // optional fallback
            }
          },
        ),

      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Welcome to Stock Manager')),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

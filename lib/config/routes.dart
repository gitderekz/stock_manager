// config/routes.dart
import 'package:flutter/material.dart';
import '../pages/login_screen.dart';
import '../models/product.dart';
import '../pages/main_navigation.dart';
import '../pages/product_details.dart';
import '../pages/product_form.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case '/product':
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsPage(product: product),
        );
      case '/add-product':
        return MaterialPageRoute(builder: (_) => const ProductForm());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
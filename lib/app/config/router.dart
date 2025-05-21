import 'package:flutter/material.dart';
import 'package:stock_manager/presentation/screens/auth/login_screen.dart';
import 'package:stock_manager/presentation/screens/products/product_list_screen.dart';
import 'package:stock_manager/presentation/screens/inventory/stock_movement_screen.dart';
import 'package:stock_manager/presentation/screens/notifications/notifications_screen.dart';
import 'package:stock_manager/presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/products':
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case '/products/add':
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      case '/products/detail':
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            productId: settings.arguments as int,
          ),
        );
      case '/inventory':
        return MaterialPageRoute(
          builder: (_) => StockMovementScreen(
            productId: settings.arguments as int,
          ),
        );
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
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
class AppRoutes {
  static const String login = '/login';
  static const String products = '/products';
  static const String inventory = '/inventory';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // ✅ Add these missing routes
  static const String addProduct = '/products/add';
  static const String productDetail = '/products/detail';
}





// example for AddProductScreen
class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: const Center(child: Text('Add Product Form Here')),
    );
  }
}

// example for ProductDetailScreen
class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Detail $productId')),
      body: Center(child: Text('Detail for product ID $productId')),
    );
  }
}

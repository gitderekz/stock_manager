// controllers/stock_controller.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/models/product.dart';
import 'package:stock_manager/utils/database.dart';

class StockController extends Cubit<List<Product>> {
  StockController() : super([]);

  Future<void> stockIn(int productId, int quantity) async {
    // Implementation
  }

  Future<void> stockOut(int productId, int quantity) async {
    // Implementation
  }

  Future<void> updateStock(int id, String type, int quantity) async {
    final current = await AppDatabase.getProducts();
    final product = current.firstWhere((p) => p.id == id);
    final newQuantity = type == 'in'
        ? product.quantity + quantity
        : product.quantity - quantity;

    await AppDatabase.updateStock(id, newQuantity);
  }
}
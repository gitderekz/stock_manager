import 'package:stock_manager/domain/entities/stock_movement.dart';
import 'package:stock_manager/domain/repositories/inventory_repository.dart';
import 'package:stock_manager/data/datasources/remote/inventory_api.dart';
// import 'package:stock_manager/data/datasources/local/database_helper.dart';
import 'package:stock_manager/utils/helpers/database_helper.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryApi inventoryApi;
  final DatabaseHelper databaseHelper;

  InventoryRepositoryImpl({
    required this.inventoryApi,
    required this.databaseHelper,
  });

  @override
  Future<List<StockMovement>> getStockMovements(int productId) async {
    // Implementation here
    return [];
  }

  @override
  Future<void> addStockMovement(StockMovement movement) async {
    // Implementation here
  }

  @override
  Future<void> updateInventory(int productId, int quantity) async {
    // Implementation here
  }
}
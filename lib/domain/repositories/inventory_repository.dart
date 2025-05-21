import 'package:stock_manager/domain/entities/stock_movement.dart';

abstract class InventoryRepository {
  Future<List<StockMovement>> getStockMovements(int productId);
  Future<void> addStockMovement(StockMovement movement);
  Future<void> updateInventory(int productId, int quantity);
}
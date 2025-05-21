import 'package:dio/dio.dart';
import 'package:stock_manager/domain/entities/stock_movement.dart';

class InventoryApi {
  final Dio dio;

  InventoryApi(this.dio);

  Future<void> addStockMovement(StockMovement movement) async {
    await dio.post('/inventory/movements', data: movement.toJson());
  }

  Future<List<StockMovement>> getStockMovements(int productId) async {
    final response = await dio.get('/inventory/movements/$productId');
    return (response.data as List)
        .map((json) => StockMovement.fromJson(json))
        .toList();
  }

  Future<void> updateInventory(int productId, int quantity) async {
    await dio.put('/inventory/$productId', data: {'quantity': quantity});
  }
}

// controllers/stock_controller.dart
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/models/product.dart';
import 'package:stock_manager/utils/database.dart';


// lib/controllers/stock_controller.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/models/stock_movement.dart';
import 'package:stock_manager/utils/database_helper.dart';
import 'package:stock_manager/utils/api_service.dart';


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



class StockCubit extends Cubit<StockState> {
  final DatabaseHelper dbHelper;

  StockCubit(this.dbHelper) : super(StockInitial()) {
    loadMovements();
  }

  Future<void> loadMovements() async {
    emit(StockLoading());
    try {
      final response = await ApiService.get('stock-movements');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final movements = data.map((json) => StockMovement.fromJson(json)).toList();
        emit(StockLoaded(movements: movements));
      } else {
        throw Exception('Failed to load movements');
      }
    } catch (e) {
      final localMovements = await dbHelper.getStockMovements();
      emit(StockLoaded(movements: localMovements));
    }
  }

  Future<void> recordMovement(StockMovement movement) async {
    try {
      // Try to send to server first
      final response = await ApiService.post(
        'stock-movements',
        movement.toJson(),
      );

      if (response.statusCode == 201) {
        await loadMovements();
      } else {
        throw Exception('Failed to record movement');
      }
    } catch (e) {
      // If offline, store locally
      await dbHelper.addStockMovement(movement);
      await dbHelper.addToSyncQueue(
        'stock_movements',
        movement.id,
        'create',
        movement.toMap(),
      );
      emit(StockMovementAddedLocally(movement));
    }
  }
}
abstract class StockState {}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockMovement> movements;
  StockLoaded({required this.movements});
}

class StockMovementAddedLocally extends StockState {
  final StockMovement movement;
  StockMovementAddedLocally(this.movement);
}

class StockError extends StockState {
  final String message;
  StockError(this.message);
}
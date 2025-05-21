part of 'stock_movement_bloc.dart';

abstract class StockMovementEvent {}

class LoadStockMovements extends StockMovementEvent {}

class AddStockMovement extends StockMovementEvent {
  final StockMovement movement;

  AddStockMovement(this.movement);
}
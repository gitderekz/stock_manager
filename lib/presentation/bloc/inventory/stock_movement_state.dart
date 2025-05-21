part of 'stock_movement_bloc.dart';

abstract class StockMovementState {}

class StockMovementInitial extends StockMovementState {}

class StockMovementLoading extends StockMovementState {}

class StockMovementLoaded extends StockMovementState {
  final List<StockMovement> movements;

  StockMovementLoaded(this.movements);
}

class StockMovementError extends StockMovementState {
  final String message;

  StockMovementError(this.message);
}
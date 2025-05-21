import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/domain/entities/stock_movement.dart';
import 'package:stock_manager/domain/repositories/inventory_repository.dart';

part 'stock_movement_event.dart';
part 'stock_movement_state.dart';

class StockMovementBloc extends Bloc<StockMovementEvent, StockMovementState> {
  final InventoryRepository inventoryRepository;
  final int productId;

  StockMovementBloc({
    required this.inventoryRepository,
    required this.productId,
  }) : super(StockMovementInitial()) {
    on<LoadStockMovements>(_onLoadStockMovements);
    on<AddStockMovement>(_onAddStockMovement);
  }

  Future<void> _onLoadStockMovements(
      LoadStockMovements event,
      Emitter<StockMovementState> emit,
      ) async {
    emit(StockMovementLoading());
    try {
      final movements = await inventoryRepository.getStockMovements(productId);
      emit(StockMovementLoaded(movements));
    } catch (e) {
      emit(StockMovementError('Failed to load stock movements'));
    }
  }

  Future<void> _onAddStockMovement(
      AddStockMovement event,
      Emitter<StockMovementState> emit,
      ) async {
    try {
      await inventoryRepository.addStockMovement(event.movement);
      add(LoadStockMovements());
    } catch (e) {
      emit(StockMovementError('Failed to add stock movement'));
    }
  }
}
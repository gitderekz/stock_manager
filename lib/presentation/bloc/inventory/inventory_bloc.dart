// lib/presentation/bloc/inventory/inventory_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/domain/entities/inventory_summary.dart';
import 'package:stock_manager/domain/repositories/inventory_repository.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc(this.repository) : super(InventoryInitial()) {
    on<LoadInventorySummary>((event, emit) async {
      emit(InventoryLoading());
      try {
        final summary = await repository.getInventorySummary();
        emit(InventoryLoaded(summary));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });
  }
}
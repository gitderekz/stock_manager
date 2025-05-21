import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/domain/repositories/sync_repository.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository syncRepository;

  SyncBloc(this.syncRepository) : super(SyncInitial()) {
    on<SyncData>(_onSyncData);
    on<CheckSyncStatus>(_onCheckSyncStatus);
  }

  Future<void> _onSyncData(
      SyncData event,
      Emitter<SyncState> emit,
      ) async {
    emit(SyncInProgress());
    try {
      final result = await syncRepository.processSync();
      emit(SyncSuccess(result.syncedItems));
    } catch (e) {
      emit(SyncError('Sync failed: ${e.toString()}'));
    }
  }

  Future<void> _onCheckSyncStatus(
      CheckSyncStatus event,
      Emitter<SyncState> emit,
      ) async {
    final pendingCount = await syncRepository.getPendingSyncCount();
    emit(SyncStatus(pendingCount));
  }
}
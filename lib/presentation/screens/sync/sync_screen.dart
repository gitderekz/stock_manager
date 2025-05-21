import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/presentation/bloc/sync/sync_bloc.dart';
import 'package:stock_manager/utils/constants/strings.dart';
import 'package:stock_manager/utils/extensions/context_extensions.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.sync),
      ),
      body: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess) {
            context.showSnackBar('${state.syncedItems} items synced');
          } else if (state is SyncError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.sync, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          state is SyncInProgress
                              ? 'Syncing data...'
                              : 'Sync your offline changes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (state is SyncStatus)
                          Text('Pending items: ${state.pendingCount}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: state is SyncInProgress
                              ? null
                              : () => context.read<SyncBloc>().add(SyncData()),
                          child: const Text(Strings.syncNow),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is SyncInProgress)
                  const LinearProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}
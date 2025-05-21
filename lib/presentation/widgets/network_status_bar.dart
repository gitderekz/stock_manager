import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/presentation/cubits/connectivity_cubit.dart';

class NetworkStatusBar extends StatelessWidget {
  const NetworkStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (state is ConnectivityDisconnected) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.red,
            child: const Center(
              child: Text(
                'Offline Mode - Changes will sync when online',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
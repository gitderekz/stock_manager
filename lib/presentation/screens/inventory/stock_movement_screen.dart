import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/presentation/bloc/inventory/stock_movement_bloc.dart';
import 'package:stock_manager/presentation/widgets/inventory/stock_movement_form.dart';
import 'package:stock_manager/utils/constants/strings.dart';

class StockMovementScreen extends StatelessWidget {
  final int productId;

  const StockMovementScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.stockMovement),
      ),
      body: BlocProvider(
        create: (context) => StockMovementBloc(
          inventoryRepository: context.read(),
          productId: productId,
        )..add(LoadStockMovements()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StockMovementForm(productId: productId),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<StockMovementBloc, StockMovementState>(
                  builder: (context, state) {
                    if (state is StockMovementLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is StockMovementLoaded) {
                      if (state.movements.isEmpty) {
                        return Center(
                          child: Text(Strings.noMovementsFound),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.movements.length,
                        itemBuilder: (context, index) {
                          final movement = state.movements[index];
                          return ListTile(
                            title: Text('${movement.movementType}: ${movement.quantity}'),
                            subtitle: Text(movement.movementDate.toString()),
                            trailing: Text(movement.reference ?? ''),
                          );
                        },
                      );
                    } else if (state is StockMovementError) {
                      return Center(
                        child: Text(state.message),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
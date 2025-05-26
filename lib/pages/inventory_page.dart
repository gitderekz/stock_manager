// pages/inventory_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/product_controller.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductLoaded) {
          final lowStockItems = state.products
              .where((p) => p.quantity <= p.lowStockThreshold)
              .toList();
// print("INVENTORY: ${state.products.first.name}, ${state.products.first.quantity}, ${state.products.first.lowStockThreshold}");
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Low Stock Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (lowStockItems.isEmpty)
                const Card(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No low stock items'),
                ))
              else
                ...lowStockItems.map((product) => Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text('Stock: ${product.quantity}'),
                    trailing: const Icon(Icons.warning, color: Colors.orange),
                  ),
                )),
            ],
          );
        }
        return const Center(child: Text('Error loading inventory'));
      },
    );
  }
}
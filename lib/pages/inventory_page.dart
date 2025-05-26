import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return _buildLoadingState(context);
        } else if (state is ProductLoaded) {
          final lowStockItems = state.products
              .where((p) => p.quantity <= p.lowStockThreshold)
              .toList();
          return _buildInventoryView(context, lowStockItems);
        }
        return _buildErrorState(context);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading inventory...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryView(BuildContext context, List<Product> lowStockItems) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProductCubit>().fetchProducts(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Inventory Status',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (lowStockItems.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All items are well stocked',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = lowStockItems[index];
                    return _buildLowStockItem(context, product);
                  },
                  childCount: lowStockItems.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFF7043).withOpacity(0.1),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFFF7043),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current stock: ${product.quantity} (Threshold: ${product.lowStockThreshold})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFF7043).withOpacity(0.1),
              ),
              child: Text(
                '${((product.quantity / product.lowStockThreshold) * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFFF7043),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading inventory',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProductCubit>().fetchProducts(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}



// // pages/inventory_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../controllers/product_controller.dart';
//
// class InventoryPage extends StatelessWidget {
//   const InventoryPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ProductCubit, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is ProductLoaded) {
//           final lowStockItems = state.products
//               .where((p) => p.quantity <= p.lowStockThreshold)
//               .toList();
//           // print("INVENTORY: ${state.products}, ${state.products[4].name}, ${state.products[4].quantity}, ${state.products[4].lowStockThreshold}");
//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               const Text('Low Stock Items',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               if (lowStockItems.isEmpty)
//                 const Card(child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text('No low stock items'),
//                 ))
//               else
//                 ...lowStockItems.map((product) => Card(
//                   child: ListTile(
//                     title: Text(product.name),
//                     subtitle: Text('Stock: ${product.quantity}'),
//                     trailing: const Icon(Icons.warning, color: Colors.orange),
//                   ),
//                 )),
//             ],
//           );
//         }
//         return const Center(child: Text('Error loading inventory'));
//       },
//     );
//   }
// }
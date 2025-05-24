import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/product_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ProductCubit>().fetchDashboardStats(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ProductLoaded && state.stats != null) {
          final lowStockItems = state.products.where((p) => p.quantity <= p.lowStockThreshold).length;
          final totalItems = state.products.length;
          final totalValue = state.products.fold(0.0, (sum, p) => (/*sum +*/ (p.basePrice * p.quantity)));
          return RefreshIndicator(
            onRefresh: () => context.read<ProductCubit>().fetchDashboardStats(), // Refresh stats
            // onRefresh: () async {
            //   await context.read<ProductCubit>().fetchProducts(); // Refresh products list
            //   await context.read<ProductCubit>().fetchDashboardStats(); // Refresh stats
            // },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensures scroll even if content is small
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      // _buildStatCard(context, 'Total Items', '$totalItems', Icons.inventory),
                      // const SizedBox(width: 10),
                      // _buildStatCard(context, 'Low Stock', '$lowStockItems', Icons.warning),
                      // const SizedBox(width: 10),
                      // _buildStatCard(context, 'Total Value', '\$${totalValue.toStringAsFixed(2)}', Icons.attach_money),
                      _buildStatCard(
                        context,
                        'Total Items',
                        // state.products.length.toString(),
                        state.stats?['totalProducts'].toString()??'',
                        Icons.inventory,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(context, 'Low Stock', /* lowStockItems.toString(),*/state.stats?['lowStockItems'].toString()??'', Icons.warning, Colors.orange
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(context, 'Total Inventory Value', '\$${state.stats?['totalInventory'].toStringAsFixed(2)??''}', Icons.money_outlined,Colors.blue),
                      const SizedBox(width: 10),
                      _buildStatCard(context, 'Products Listed', state.products.length.toString(), Icons.list, Colors.teal),
                    ],
                  ),
                  // Wrap(
                  //   spacing: 10,
                  //   runSpacing: 10,
                  //   children: [
                  //     _buildStatCard(context, 'Total Products', state.stats?['totalProducts'].toString() ?? '', Icons.inventory, Colors.blue),
                  //     _buildStatCard(context, 'Low Stock', state.stats?['lowStockItems'].toString() ?? '', Icons.warning, Colors.orange),
                  //     _buildStatCard(context, 'Inventory Qty', state.stats?['totalInventory'].toString() ?? '', Icons.storage, Colors.green),
                  //     _buildStatCard(context, 'Products Listed', state.products.length.toString(), Icons.list, Colors.teal),
                  //   ],
                  // ),

                  const SizedBox(height: 20),

                  const Text('Recent Activities', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  ...state.recentMovements.take(5).map((movement) => ListTile(
                    leading: Icon(movement.type == 'in'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward),
                    title: Text(movement.productName),
                    subtitle: Text('${movement.quantity} items - ${movement.date}'),
                  )),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ProductCubit>().fetchDashboardStats(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: const Center(child: Text('Error loading data')),
              ),
            ],
          ),
        );

      },
    );
  }

  // Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
  //   return Expanded(
  //     child: Card(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Icon(icon, size: 30),
  //             const SizedBox(height: 10),
  //             Text(title, style: Theme.of(context).textTheme.bodySmall),
  //             Text(value, style: Theme.of(context).textTheme.displayMedium),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width / 2 - 22, // 2 cards per row with spacing
  //     child: Card(
  //       color: color.withOpacity(0.08),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       elevation: 4,
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Icon(icon, size: 32, color: color),
  //             const SizedBox(height: 10),
  //             Text(
  //               title,
  //               style: TextStyle(fontSize: 14, color: Colors.grey[700]),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               value,
  //               style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, [Color? iconColor]) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: iconColor ?? Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }

}
// ***************************************************




// // pages/dashboard_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../controllers/product_controller.dart';
//
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ProductCubit, ProductState>(
//       builder: (context, state) {
//         // Handle loading state
//         if (state is ProductLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         // Handle error state
//         if (state is ProductError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(state.message),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => context.read<ProductCubit>().fetchDashboardStats(),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // Handle loaded state
//         if (state is ProductLoaded && state.stats != null) {
//           final lowStockItems = state.products.where((p) => p.quantity <= p.lowStockThreshold).length;
//
//           // final totalItems = state.products.length;
//           // final totalValue = state.products.fold(0.0, (sum, p) => (/*sum +*/ (p.basePrice * p.quantity)));
//
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Summary Cards
//                 Row(
//                   children: [
//                     // _buildStatCard(context, 'Total Items', '$totalItems', Icons.inventory),
//                     // const SizedBox(width: 10),
//                     // _buildStatCard(context, 'Low Stock', '$lowStockItems', Icons.warning),
//                     // const SizedBox(width: 10),
//                     // _buildStatCard(context, 'Total Value', '\$${totalValue.toStringAsFixed(2)}', Icons.attach_money),
//                     _buildStatCard(
//                         context,
//                         'Total Items',
//                         state.products.length.toString(),
//                         Icons.inventory),
//                     const SizedBox(width: 10),
//                     _buildStatCard(
//                         context,
//                         'Low Stock',
//                         lowStockItems.toString(),
//                         Icons.warning),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Recent Activities
//                 const Text('Recent Activities', style: TextStyle(fontSize: 18)),
//                 const SizedBox(height: 10),
//                 ...state.recentMovements.take(5).map((movement) => ListTile(
//                   leading: Icon(movement.type == 'in'
//                       ? Icons.arrow_downward
//                       : Icons.arrow_upward),
//                   title: Text(movement.productName),
//                   subtitle: Text('${movement.quantity} items - ${movement.date}'),
//                 )).toList(),
//               ],
//             ),
//           );
//         }
//
//         // Fallback for unexpected states
//         return const Center(child: Text('Error loading data'));
//       },
//     );
//   }
//
//   Widget _buildStatCard(
//       BuildContext context, String title, String value, IconData icon) {
//     return Expanded(
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(icon, size: 30),
//               const SizedBox(height: 10),
//               Text(title, style: Theme.of(context).textTheme.bodySmall),
//               Text(value, style: Theme.of(context).textTheme.displayMedium),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// // **************************************



// // pages/dashboard_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../controllers/product_controller.dart';
//
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ProductCubit, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoaded && state.stats != null) {
//           final lowStockItems = state.products.where((p) => p.quantity <= p.lowStockThreshold).length;
//
//           if (state is ProductError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(state.message),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => context.read<ProductCubit>().fetchDashboardStats(),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Summary Cards
//                 Row(
//                   children: [
//                     _buildStatCard(context, 'Total Items', state.products.length.toString(), Icons.inventory),
//                     const SizedBox(width: 10),
//                     _buildStatCard(context, 'Low Stock', lowStockItems.toString(), Icons.warning),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Recent Activities
//                 const Text('Recent Activities', style: TextStyle(fontSize: 18)),
//                 const SizedBox(height: 10),
//                 ...state.recentMovements.take(5).map((movement) =>
//                     ListTile(
//                       leading: Icon(movement.type == 'in' ? Icons.arrow_downward : Icons.arrow_upward),
//                       title: Text(movement.productName),
//                       subtitle: Text('${movement.quantity} items - ${movement.date}'),
//                     )
//                 ).toList(),
//               ],
//             ),
//           );
//         }
//         else if (state is ProductLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return const Center(child: Text('Error loading data'));
//       },
//     );
//   }
//
//   Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
//     return Expanded(
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(icon, size: 30),
//               const SizedBox(height: 10),
//               Text(title, style: Theme.of(context).textTheme.bodySmall),
//               Text(value, style: Theme.of(context).textTheme.displayMedium),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
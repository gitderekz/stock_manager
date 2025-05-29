import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stock_manager/controllers/product_controller.dart';
import 'package:stock_manager/utils/api_service.dart';
import '../models/product.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _dateRange;
  final currencyFormat = NumberFormat.currency(symbol: 'Tsh ');
  Future<Map<String, dynamic>>? _reportFuture;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reportFuture = _fetchReport();
  }

  void _refreshReport() {
    setState(() {
      _reportFuture = _fetchReport();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange ?? initialDateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _reportFuture = _fetchReport(); // ✅ Fetch the report immediately after updating the date
      });
    }
  }

  Future<Map<String, dynamic>> _fetchReport() async {
    // final params = {
    //   if (_dateRange != null) 'startDate': _dateRange!.start.toIso8601String(),
    //   if (_dateRange != null) 'endDate': _dateRange!.end.toIso8601String(),
    // };
    final range = _dateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final params = {
      'startDate': range.start.toIso8601String(),
      'endDate': range.end.toIso8601String(),
    };


    try {
      final response = await ApiService.get('products/sales-report', params: params);
      print("response, ${response}");
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load report');
      }
    } catch (e) {
      debugPrint('Fetch report error: $e');
      throw Exception('Error fetching report');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            indicatorSize: TabBarIndicatorSize.tab, // <- Ensures full tab width
            tabs: const [
              Tab(text: 'Low Stock'),
              Tab(text: 'Sales Report'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLowStockView(context),
              _buildSalesReportView(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockView(BuildContext context) {
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

  Widget _buildSalesReportView(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _reportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        final data = snapshot.data!;
        final report = List.from(data['report'] ?? []);
        final total = data['total'] ?? 0;

        return Column(
          children: [
            ListTile(
              title: Text(
                _dateRange == null
                    ? 'All Time Sales'
                    : '${DateFormat.yMd().format(_dateRange!.start)} - ${DateFormat.yMd().format(_dateRange!.end)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  _selectDateRange(context);
                  _refreshReport();
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: report.length,
                itemBuilder: (context, index) {
                  final item = report[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        item['product'] ?? 'Unknown Product',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat.yMd().add_jm().format(DateTime.parse(item['date'])),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            // '${item['quantity']} × ${currencyFormat.format(item['unit_price'])}',
                            '${item['quantity']} × ${currencyFormat.format(double.tryParse(item['unit_price'].toString()) ?? 0)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            currencyFormat.format(item['total_value']),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyFormat.format(total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
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
            'Loading data...',
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
                'Low Stock Items',
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

  Widget _buildErrorState(BuildContext context, [String? message]) {
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
            message ?? 'Error loading data',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_tabController.index == 0) {
                context.read<ProductCubit>().fetchProducts();
              } else {
                // Re-trigger the FutureBuilder by resetting the future
                setState(() {
                  _reportFuture = _fetchReport();
                });
              }
            },
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
// *************************************



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../controllers/product_controller.dart';
// import '../models/product.dart';
//
// class InventoryPage extends StatelessWidget {
//   const InventoryPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ProductCubit, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoading) {
//           return _buildLoadingState(context);
//         } else if (state is ProductLoaded) {
//           final lowStockItems = state.products
//               .where((p) => p.quantity <= p.lowStockThreshold)
//               .toList();
//           return _buildInventoryView(context, lowStockItems);
//         }
//         return _buildErrorState(context);
//       },
//     );
//   }
//
//   Widget _buildLoadingState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation(
//                 Theme.of(context).colorScheme.primary),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading inventory...',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInventoryView(BuildContext context, List<Product> lowStockItems) {
//     return RefreshIndicator(
//       onRefresh: () => context.read<ProductCubit>().fetchProducts(),
//       child: CustomScrollView(
//         slivers: [
//           SliverPadding(
//             padding: const EdgeInsets.all(16),
//             sliver: SliverToBoxAdapter(
//               child: Text(
//                 'Inventory Status',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           if (lowStockItems.isEmpty)
//             SliverFillRemaining(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.check_circle_outline,
//                       size: 64,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'All items are well stocked',
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             SliverPadding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               sliver: SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                       (context, index) {
//                     final product = lowStockItems[index];
//                     return _buildLowStockItem(context, product);
//                   },
//                   childCount: lowStockItems.length,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLowStockItem(BuildContext context, Product product) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: const Color(0xFFFF7043).withOpacity(0.1),
//               ),
//               child: Icon(
//                 Icons.warning_amber_rounded,
//                 color: const Color(0xFFFF7043),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Current stock: ${product.quantity} (Threshold: ${product.lowStockThreshold})',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: const Color(0xFFFF7043).withOpacity(0.1),
//               ),
//               child: Text(
//                 '${((product.quantity / product.lowStockThreshold) * 100).toStringAsFixed(0)}%',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: const Color(0xFFFF7043),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 48,
//             color: Theme.of(context).colorScheme.error,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Error loading inventory',
//             style: Theme.of(context).textTheme.bodyLarge,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () => context.read<ProductCubit>().fetchProducts(),
//             style: ElevatedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// // // pages/inventory_page.dart
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../controllers/product_controller.dart';
// //
// // class InventoryPage extends StatelessWidget {
// //   const InventoryPage({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocBuilder<ProductCubit, ProductState>(
// //       builder: (context, state) {
// //         if (state is ProductLoading) {
// //           return const Center(child: CircularProgressIndicator());
// //         } else if (state is ProductLoaded) {
// //           final lowStockItems = state.products
// //               .where((p) => p.quantity <= p.lowStockThreshold)
// //               .toList();
// //           // print("INVENTORY: ${state.products}, ${state.products[4].name}, ${state.products[4].quantity}, ${state.products[4].lowStockThreshold}");
// //           return ListView(
// //             padding: const EdgeInsets.all(16),
// //             children: [
// //               const Text('Low Stock Items',
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //               const SizedBox(height: 10),
// //               if (lowStockItems.isEmpty)
// //                 const Card(child: Padding(
// //                   padding: EdgeInsets.all(16),
// //                   child: Text('No low stock items'),
// //                 ))
// //               else
// //                 ...lowStockItems.map((product) => Card(
// //                   child: ListTile(
// //                     title: Text(product.name),
// //                     subtitle: Text('Stock: ${product.quantity}'),
// //                     trailing: const Icon(Icons.warning, color: Colors.orange),
// //                   ),
// //                 )),
// //             ],
// //           );
// //         }
// //         return const Center(child: Text('Error loading inventory'));
// //       },
// //     );
// //   }
// // }
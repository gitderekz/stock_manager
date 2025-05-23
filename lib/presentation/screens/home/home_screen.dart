// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/app/config/router.dart';
import 'package:stock_manager/app/config/theme.dart';
import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/domain/entities/stock_movement.dart';
import 'package:stock_manager/presentation/bloc/auth/auth_bloc.dart';
import 'package:stock_manager/presentation/bloc/inventory/inventory_bloc.dart';
import 'package:stock_manager/presentation/bloc/network/network_bloc.dart';
import 'package:stock_manager/presentation/bloc/stock_movement/stock_movement_bloc.dart';
import 'package:stock_manager/utils/constants/strings.dart';
import 'package:stock_manager/utils/extensions/context_extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<InventoryBloc>().add(LoadInventorySummary());
    context.read<StockMovementBloc>().add(LoadRecentMovements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileMenu(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: BlocListener<NetworkBloc, NetworkState>(
        listener: (context, state) {
          if (state is NetworkConnected) {
            // Refresh data when connection is restored
            context.read<InventoryBloc>().add(LoadInventorySummary());
            context.read<StockMovementBloc>().add(LoadRecentMovements());
          }
        },
        child: Column(
          children: [
            // Network status bar
            BlocBuilder<NetworkBloc, NetworkState>(
              builder: (context, state) {
                final isOnline = state is NetworkConnected;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: isOnline ? AppTheme.successColor : AppTheme.warningColor,
                  child: Center(
                    child: Text(
                      isOnline ? Strings.online : Strings.offline,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),

            // Main content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<InventoryBloc>().add(LoadInventorySummary());
                  context.read<StockMovementBloc>().add(LoadRecentMovements());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quick stats section
                        _buildInventorySummary(),
                        const SizedBox(height: 24),

                        // Low stock alerts
                        _buildLowStockAlerts(),
                        const SizedBox(height: 24),

                        // Recent activities
                        _buildRecentActivities(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.inventory),
        child: const Icon(Icons.inventory),
        tooltip: 'Stock Movement',
      ),
    );
  }

  // ... (keep existing _showProfileMenu method)

  Widget _buildInventorySummary() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is InventoryError) {
          return Center(child: Text(state.message));
        }

        final totalItems = state is InventoryLoaded ? state.summary.totalItems : 0;
        final lowStockItems = state is InventoryLoaded ? state.summary.lowStockItems : 0;
        final outOfStockItems = state is InventoryLoaded ? state.summary.outOfStockItems : 0;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.inventorySummary,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      value: totalItems.toString(),
                      label: Strings.totalItems,
                      icon: Icons.inventory,
                      color: AppTheme.primaryColor,
                    ),
                    _StatCard(
                      value: lowStockItems.toString(),
                      label: Strings.lowStock,
                      icon: Icons.warning,
                      color: AppTheme.warningColor,
                    ),
                    _StatCard(
                      value: outOfStockItems.toString(),
                      label: Strings.outOfStock,
                      icon: Icons.error,
                      color: AppTheme.errorColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLowStockAlerts() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final lowStockProducts = state is InventoryLoaded
            ? state.summary.lowStockProducts
            : <Product>[];

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Strings.lowStockAlerts,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.warning, color: AppTheme.warningColor),
                  ],
                ),
                const SizedBox(height: 16),
                if (lowStockProducts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Strings.noLowStockItems,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  Column(
                    children: lowStockProducts
                        .take(5)
                        .map((product) => _LowStockItem(product: product))
                        .toList(),
                  ),
                if (lowStockProducts.length > 5)
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.products,
                      arguments: {'filter': 'low-stock'},
                    ),
                    child: Text(Strings.viewAll),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    return BlocBuilder<StockMovementBloc, StockMovementState>(
      builder: (context, state) {
        final movements = state is StockMovementLoaded
            ? state.recentMovements
            : <StockMovement>[];

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.recentActivities,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (movements.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Strings.noRecentActivities,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  Column(
                    children: movements
                        .take(5)
                        .map((movement) => _ActivityItem(movement: movement))
                        .toList(),
                  ),
                if (movements.length > 5)
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.inventory,
                    ),
                    child: Text(Strings.viewAll),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LowStockItem extends StatelessWidget {
  final Product product;

  const _LowStockItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: product.imageUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(product.imageUrl!))
          : const CircleAvatar(child: Icon(Icons.inventory)),
      title: Text(product.name),
      subtitle: Text('${Strings.remaining}: ${product.quantity}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: product.id,
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final StockMovement movement;

  const _ActivityItem({required this.movement});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        movement.movementType == 'in' ? Icons.arrow_downward : Icons.arrow_upward,
        color: movement.movementType == 'in'
            ? AppTheme.successColor
            : AppTheme.errorColor,
      ),
      title: Text(movement.productName),
      subtitle: Text('${movement.quantity} items • ${movement.reference}'),
      trailing: Text(
        context.formatDateTime(movement.movementDate),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}




// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:stock_manager/app/config/router.dart';
// import 'package:stock_manager/app/config/theme.dart';
// import 'package:stock_manager/domain/entities/product.dart';
// import 'package:stock_manager/presentation/bloc/products/product_list_bloc.dart';
// import 'package:stock_manager/presentation/bloc/auth/auth_bloc.dart';
// import 'package:stock_manager/presentation/cubits/connectivity_cubit.dart';
// import 'package:stock_manager/utils/constants/strings.dart';
// import 'package:stock_manager/utils/extensions/context_extensions.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//   void check()async{
//     final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(Strings.appName),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () => _showProfileMenu(context),
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
//           ),
//           // IconButton(
//           //   icon: const Icon(Icons.logout),
//           //   onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
//           // ),
//         ],
//       ),
//       body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
//         builder: (context, connectivityState) {
//           final isOnline = connectivityState is ConnectivityConnected;
//
//           return Column(
//             children: [
//               // Connection status indicator
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 color: isOnline
//                     ? AppTheme.successColor
//                     : AppTheme.warningColor,
//                 child: Center(
//                   child: Text(
//                     isOnline ? Strings.online : Strings.offline,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//
//               // Main content
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Quick stats section
//                         _buildQuickStatsSection(),
//                         const SizedBox(height: 24),
//
//                         // // Quick actions
//                         // _buildQuickActionsSection(context),
//                         // const SizedBox(height: 24),
//
//                         // Low stock alerts
//                         _buildLowStockSection(),
//                         const SizedBox(height: 24),
//
//                         // Recent activities
//                         _buildRecentActivitiesSection(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _showProfileMenu(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, AppRoutes.profile);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.read<AuthBloc>().add(LogoutRequested());
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildQuickStatsSection() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               Strings.quickStats,
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             BlocBuilder<ProductListBloc, ProductListState>(
//               builder: (context, state) {
//                 // Handle different states
//                 if (state is ProductListLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (state is ProductListError) {
//                   return Center(child: Text(state.message));
//                 }
//
//                 int totalProducts = 0;
//                 int lowStockItems = 0;
//                 int outOfStockItems = 0;
//
//                 if (state is ProductListLoaded) {
//                   totalProducts = state.products.length;
//                   lowStockItems = state.products.where((p) =>
//                   p.quantity < p.lowStockThreshold && p.quantity > 0).length;
//                   outOfStockItems = state.products.where((p) => p.quantity <= 0).length;
//                 }
//
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _StatItem(
//                       value: state is ProductListLoaded ? totalProducts.toString() : '--',
//                       label: Strings.totalProducts,
//                       icon: Icons.inventory,
//                     ),
//                     _StatItem(
//                       value: state is ProductListLoaded ? lowStockItems.toString() : '--',
//                       label: Strings.lowStock,
//                       icon: Icons.warning,
//                       color: AppTheme.warningColor,
//                     ),
//                     _StatItem(
//                       value: state is ProductListLoaded ? outOfStockItems.toString() : '--',
//                       label: Strings.outOfStock,
//                       icon: Icons.error,
//                       color: AppTheme.errorColor,
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickActionsSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           Strings.quickActions,
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 16),
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: 2,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: 1.5,
//           children: [
//             _QuickActionCard(
//               icon: Icons.add,
//               label: Strings.addProduct,
//               color: AppTheme.primaryColor,
//               onTap: () => Navigator.pushNamed(context, AppRoutes.addProduct),
//             ),
//             _QuickActionCard(
//               icon: Icons.list,
//               label: Strings.viewProducts,
//               color: AppTheme.secondaryColor,
//               onTap: () => Navigator.pushNamed(context, AppRoutes.products/*productList*/),
//             ),
//             _QuickActionCard(
//               icon: Icons.shopping_cart,
//               label: Strings.newOrder,
//               color: AppTheme.tertiaryColor,
//               onTap: () => Navigator.pushNamed(context, AppRoutes.createOrder),
//             ),
//             _QuickActionCard(
//               icon: Icons.assessment,
//               label: Strings.reports,
//               color: AppTheme.accentColor,
//               onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLowStockSection() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   Strings.lowStockAlerts,
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.warning, color: AppTheme.warningColor),
//               ],
//             ),
//             const SizedBox(height: 16),
//             BlocBuilder<ProductListBloc, ProductListState>(
//               builder: (context, state) {
//                 if (state is ProductListLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (state is ProductListError) {
//                   return Center(child: Text(state.message));
//                 }
//
//                 if (state is ProductListInitial) {
//                   return const Center(child: Text(Strings.loadingProducts));
//                 }
//
//                 if (state is ProductListLoaded) {
//                   final lowStockProducts = state.products
//                       .where((p) => p.quantity < p.lowStockThreshold && p.quantity > 0)
//                       .take(5)
//                       .toList();
//
//                   if (lowStockProducts.isEmpty) {
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         Strings.noLowStockItems,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                     );
//                   }
//
//                   return Column(
//                     children: lowStockProducts.map((product) =>
//                         _LowStockItem(product: product)
//                     ).toList(),
//                   );
//                 }
//
//                 return const SizedBox();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildRecentActivitiesSection() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               Strings.recentActivities,
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             // TODO: Replace with actual recent activities from your backend
//             _ActivityItem(
//               icon: Icons.inventory,
//               title: "Stock Update",
//               description: "Added 10 iPhone 13 Pro",
//               time: "2 hours ago",
//             ),
//             _ActivityItem(
//               icon: Icons.point_of_sale,
//               title: "Sale Completed",
//               description: "Sold 2 Samsung Galaxy S22",
//               time: "5 hours ago",
//             ),
//             _ActivityItem(
//               icon: Icons.person_add,
//               title: "New User",
//               description: "Manager account created",
//               time: "Yesterday",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _StatItem extends StatelessWidget {
//   final String value;
//   final String label;
//   final IconData icon;
//   final Color? color;
//
//   const _StatItem({
//     required this.value,
//     required this.label,
//     required this.icon,
//     this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Icon(icon, size: 32, color: color ?? Theme.of(context).primaryColor),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
//           ),
//         ),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       ],
//     );
//   }
// }
//
// class _QuickActionCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _QuickActionCard({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       color: color.withOpacity(0.1),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 32, color: color),
//               const SizedBox(height: 8),
//               Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _LowStockItem extends StatelessWidget {
//   final Product product;
//
//   const _LowStockItem({required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: product.imageUrl != null
//           ? CircleAvatar(backgroundImage: NetworkImage(product.imageUrl!))
//           : const CircleAvatar(child: Icon(Icons.inventory)),
//       title: Text(product.name),
//       subtitle: Text('${Strings.remaining}: ${product.quantity}'),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: () => Navigator.pushNamed(
//         context,
//         AppRoutes.productDetail,
//         arguments: product.id,
//       ),
//     );
//   }
// }
//
// class _ActivityItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;
//   final String time;
//
//   const _ActivityItem({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.time,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 24, color: AppTheme.secondaryColor),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(description),
//               ],
//             ),
//           ),
//           Text(
//             time,
//             style: Theme.of(context).textTheme.bodySmall,
//           ),
//         ],
//       ),
//     );
//   }
// }
// // *****************************************




// import 'package:flutter/material.dart';
// import 'package:stock_manager/presentation/screens/products/product_list_screen.dart';
// import 'package:stock_manager/presentation/screens/inventory/stock_movement_screen.dart';
// import 'package:stock_manager/presentation/screens/notifications/notifications_screen.dart';
// import 'package:stock_manager/presentation/screens/settings/settings_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//
//   // Dummy productId to pass for inventory screen (replace with actual logic if needed)
//   final int _dummyProductId = 1;
//
//   final List<Widget> _screens = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _screens.addAll([
//       const ProductListScreen(),
//       StockMovementScreen(productId: _dummyProductId),
//       const NotificationsScreen(),
//       const SettingsScreen(),
//     ]);
//   }
//
//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onTabTapped,
//         selectedItemColor: Theme.of(context).primaryColor,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list),
//             label: 'Products',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.inventory_2),
//             label: 'Inventory',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Notifications',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }
// // ************************************



// import 'package:flutter/material.dart';
// import 'package:stock_manager/presentation/screens/products/product_list_screen.dart';
// import 'package:stock_manager/presentation/screens/settings/settings_screen.dart';
// import 'package:stock_manager/presentation/screens/notifications/notifications_screen.dart';
// import 'package:stock_manager/presentation/screens/sync/sync_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//
//   final List<Widget> _screens = const [
//     ProductListScreen(),
//     NotificationsScreen(),
//     SyncScreen(),
//     SettingsScreen(),
//   ];
//
//   final List<String> _titles = [
//     'Products',
//     'Notifications',
//     'Sync',
//     'Settings',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_titles[_currentIndex])),
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Products'),
//           BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
//           BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Sync'),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
//         ],
//       ),
//     );
//   }
// }

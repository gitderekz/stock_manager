import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stock_manager/models/stock_movement.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/product_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isDataFetched = false;
  final formatter = NumberFormat.currency(symbol: 'Tsh ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final productCubit = context.read<ProductCubit>();
      if (!_isDataFetched) {
        productCubit.fetchDashboardStats();
        _isDataFetched = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return _buildLoadingState();
        }

        if (state is ProductError) {
          return _buildErrorState(context, state);
        }

        if (state is ProductLoaded && state.stats != null) {
          return RefreshIndicator(
            onRefresh: () => context.read<ProductCubit>().fetchDashboardStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsGrid(context, state),
                  const SizedBox(height: 24),
                  _buildStockChart(state),
                  const SizedBox(height: 24),
                  _buildRecentActivities(state),
                ],
              ),
            ),
          );
        }

        return _buildErrorFallback(context);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Loading dashboard...', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ProductError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(state.message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProductCubit>().fetchDashboardStats(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProductLoaded state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          context,
          'Total Products',
          state.stats?['totalProducts'].toString() ?? '0',
          Icons.inventory_2_outlined,
          const Color(0xFF6A3CBC),
        ),
        _buildStatCard(
          context,
          'Low Stock',
          state.stats?['lowStockItems'].toString() ?? '0',
          Icons.warning_amber_rounded,
          const Color(0xFFFF7043),
        ),
        _buildStatCard(
          context,
          'Inventory Value',
          // '${state.stats?['totalInventoryValue']?.toStringAsFixed(2) ?? '0'}\n${state.stats?['totalInventory'].toStringAsFixed(0)??""}(Items)',
          '${formatter.format(state.stats?['totalInventoryValue'])??'0'}\nItems ${state.stats?['totalInventory'].toStringAsFixed(0)??""}',
          Icons.attach_money_outlined,
          const Color(0xFF4CAF50),
        ),
        _buildStatCard(
          context,
          'Avg. Stock',
          state.stats?['averageStock']?.toStringAsFixed(1) ?? '0',
          Icons.analytics_outlined,
          const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.4)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockChart(ProductLoaded state) {
    final lowStockItems = state.products.where((p) => p.quantity <= p.lowStockThreshold).toList();
    final normalStockItems = state.products.where((p) => p.quantity > p.lowStockThreshold).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelPlacement: LabelPlacement.onTicks,
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                majorGridLines: const MajorGridLines(width: 0.5),
              ),
              series: <ChartSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: [
                    {'category': 'Low Stock', 'value': lowStockItems.length},
                    {'category': 'Normal Stock', 'value': normalStockItems.length},
                  ],
                  xValueMapper: (data, _) => data['category'],
                  yValueMapper: (data, _) => data['value'],
                  pointColorMapper: (data, _) => data['category'] == 'Low Stock'
                      ? const Color(0xFFFF7043)
                      : const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(ProductLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {}, // Navigate to full activities screen
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...state.recentMovements.take(5).map((movement) => _buildActivityItem(context, movement)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, StockMovement movement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: movement.movementType == 'in'
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : const Color(0xFFF44336).withOpacity(0.2),
          ),
          child: Icon(
            movement.movementType == 'in' ? Icons.arrow_downward : Icons.arrow_upward,
            color: movement.movementType == 'in' ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
          ),
        ),
        title: Text(
          movement.productName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${movement.quantity} items • ${movement.date}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          movement.movementType == 'in' ? 'In' : 'Out',
          style: TextStyle(
            color: movement.movementType == 'in' ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorFallback(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProductCubit>().fetchDashboardStats(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error loading data', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
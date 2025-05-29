import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/config/env.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stock_manager/models/product.dart';
import 'package:stock_manager/utils/currency_helper.dart';
import 'package:stock_manager/utils/dialog_helper.dart';
import '../controllers/product_controller.dart';
import 'product_details.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteProduct(int productId) async {
    final shouldDelete = await DialogHelper.showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context)!.deleteConfirmation,
      confirmText: AppLocalizations.of(context)!.confirm,
      cancelText: AppLocalizations.of(context)!.cancel,
      // context: context,
      // title: 'Delete Product',
      content: 'Are you sure you want to delete this product?',
    );
    if (shouldDelete) {
      context.read<ProductCubit>().deleteProduct(productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        List<Product> displayedProducts = [];
        if (state is ProductLoaded) {
          displayedProducts = state.products.where((product) {
            return _searchQuery.isEmpty ||
                product.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.products,//'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),

            // Product list
            Expanded(
              child: _buildProductList(context, state, displayedProducts),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductList(
      BuildContext context, ProductState state, List<Product> products) {
    if (state is ProductLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
        ),
      );
    } else if (state is ProductLoaded) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProductCubit>().fetchProducts(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, product);
          },
        ),
      );
    } else if (state is ProductError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(state.message, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ProductCubit>().fetchProducts(),
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
    return const Center(child: Text('Unknown state'));
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final isLowStock = product.quantity <= product.lowStockThreshold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${Env.mediaUrl}${product.imageUrl!}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Icon(Icons.image, color: Theme.of(context).colorScheme.primary)),
                  ),
                )
                    : Center(child: Icon(Icons.image, color: Theme.of(context).colorScheme.primary)),
              ),
              const SizedBox(width: 16),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyHelper.formatCurrency(context, product.basePrice),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Stock indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isLowStock
                      ? const Color(0xFFFF7043).withOpacity(0.1)
                      : const Color(0xFF4CAF50).withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      size: 16,
                      color: isLowStock ? const Color(0xFFFF7043) : const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLowStock ? const Color(0xFFFF7043) : const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
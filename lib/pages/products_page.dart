// lib/pages/products_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/config/env.dart';
import 'package:stock_manager/models/product.dart';
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
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
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProductLoaded) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProductCubit>().fetchProducts(),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: product.imageUrl != null
                    ? Image.network(
                  '${Env.mediaUrl}${product.imageUrl!}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image),
                )
                    : const Icon(Icons.image),
                title: Text(product.name),
                subtitle: Text('Stock: ${product.quantity}'),
                trailing: product.quantity <= product.lowStockThreshold
                    ? const Icon(Icons.warning, color: Colors.orange)
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(product: product),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else if (state is ProductError) {
      return Center(child: Text(state.message));
    }
    return const Center(child: Text('Unknown state'));
  }
}



// // pages/products_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:stock_manager/config/env.dart';
// import '../controllers/product_controller.dart';
// import 'product_details.dart';
//
// class ProductsPage extends StatelessWidget {
//   const ProductsPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ProductCubit, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is ProductLoaded) {
//           return RefreshIndicator(
//             onRefresh: () => context.read<ProductCubit>().fetchProducts(),
//             child: ListView.builder(
//               itemCount: state.products.length,
//               itemBuilder: (context, index) {
//                 final product = state.products[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                   child: ListTile(
//                     leading: product.imageUrl != null
//                         ? Image.network(
//                       '${Env.mediaUrl}${product.imageUrl!}',
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) =>
//                       const Icon(Icons.image),
//                     )
//                         : const Icon(Icons.image),
//                     title: Text(product.name),
//                     subtitle: Text('Stock: ${product.quantity}'),
//                     trailing: product.quantity <= product.lowStockThreshold
//                         ? const Icon(Icons.warning, color: Colors.orange)
//                         : null,
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ProductDetailsPage(product: product),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         } else if (state is ProductError) {
//           return Center(child: Text(state.message));
//         }
//         return const Center(child: Text('Unknown state'));
//       },
//     );
//   }
// }
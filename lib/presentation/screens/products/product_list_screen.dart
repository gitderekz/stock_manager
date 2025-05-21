import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/presentation/bloc/products/product_list_bloc.dart';
import 'package:stock_manager/presentation/widgets/product/product_card.dart';
import 'package:stock_manager/presentation/widgets/empty_state.dart';
import 'package:stock_manager/presentation/widgets/loading_indicator.dart';
import 'package:stock_manager/app/config/router.dart';
import 'package:stock_manager/utils/constants/strings.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<ProductListBloc>().add(LoadProducts()),
          ),
        ],
      ),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state is ProductListLoading) {
            return const LoadingIndicator();
          } else if (state is ProductListLoaded) {
            if (state.products.isEmpty) {
              return EmptyState(
                message: Strings.noProductsFound,
                actionText: Strings.addProduct,
                onAction: () => Navigator.pushNamed(context, AppRoutes.addProduct),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductListBloc>().add(LoadProducts());
              },
              child: ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: product.id,
                    ),
                  );
                },
              ),
            );
          } else if (state is ProductListError) {
            return Center(
              child: Text(state.message),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
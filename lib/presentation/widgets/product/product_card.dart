import 'package:flutter/material.dart';
import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/utils/extensions/context_extensions.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${product.basePrice.toStringAsFixed(2)}',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
              if (product.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
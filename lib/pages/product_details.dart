// pages/product_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/config/env.dart';
import 'package:stock_manager/controllers/auth_controller.dart';
import 'package:stock_manager/controllers/stock_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({required this.product, Key? key}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final _quantityController = TextEditingController();
  String _movementType = 'in';

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: ${widget.product.quantity}',
                style: Theme.of(context).textTheme.headlineSmall),
            if (widget.product.quantity <= widget.product.lowStockThreshold)
              Text('LOW STOCK WARNING',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.red)),
            const SizedBox(height: 20),
            Text('Base Price: \$${widget.product.basePrice.toStringAsFixed(2)}'),
            if (widget.product.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(widget.product.description!),
              ),
            const Divider(height: 20),
            if (widget.product.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Image.network(
                  '${Env.mediaUrl}${widget.product.imageUrl!}',
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const Divider(height: 40),
            const Text('Stock Movement',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _movementType,
              items: const [
                DropdownMenuItem(value: 'in', child: Text('Stock In')),
                DropdownMenuItem(value: 'out', child: Text('Stock Out')),
              ],
              onChanged: (value) => setState(() => _movementType = value!),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            ElevatedButton(
              onPressed: _submitMovement,
              child: const Text('Record Movement'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitMovement() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid quantity')));
      return;
    }

    // Validate stock out doesn't exceed available quantity
    if (_movementType == 'out' && quantity > widget.product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient stock')));
      return;
    }

    final movement = StockMovement(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: widget.product.id,
      movementType: _movementType,
      quantity: quantity,
      // userId: context.read<AuthCubit>().state.user?.id ?? 1,
      userId: context.read<AuthCubit>().state.userData?['id'] ?? 1,
      movementDate: DateTime.now(),
      productName: widget.product.name,
      reference: _movementType == 'out' ? 'Sale' : 'Restock',
    );

    context.read<StockCubit>().recordMovement(movement);
    context.read<ProductCubit>().fetchProducts(); // Refresh product list
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}
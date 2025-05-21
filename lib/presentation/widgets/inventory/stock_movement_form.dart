import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/domain/entities/stock_movement.dart';
import 'package:stock_manager/presentation/bloc/inventory/stock_movement_bloc.dart';

class StockMovementForm extends StatefulWidget {
  final int productId;

  const StockMovementForm({super.key, required this.productId});

  @override
  State<StockMovementForm> createState() => _StockMovementFormState();
}

class _StockMovementFormState extends State<StockMovementForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  String _movementType = 'in';
  final _referenceController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _movementType,
                items: const [
                  DropdownMenuItem(
                    value: 'in',
                    child: Text('Stock In'),
                  ),
                  DropdownMenuItem(
                    value: 'out',
                    child: Text('Stock Out'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _movementType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Movement Type',
                ),
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference (Optional)',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Record Movement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final movement = StockMovement(
        id: 0, // Placeholder if auto-incremented in DB
        productId: widget.productId,
        movementType: _movementType,
        quantity: int.parse(_quantityController.text),
        reference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        notes: null, // Or whatever note logic you want
        userId: 1, // Replace with actual logged-in user ID
        movementDate: DateTime.now(),
      );

      context.read<StockMovementBloc>().add(AddStockMovement(movement));
    }
  }

}
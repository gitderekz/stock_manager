import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_manager/utils/haptic_feedback_helper.dart';
import 'dart:io';
import '../controllers/product_controller.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isUploading ? null : _submitForm,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 24),
                  _buildFormFields(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          if (_isUploading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: _imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(_imageFile!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Product Image',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            prefixIcon: Icon(
              Icons.shopping_bag_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Price',
            prefixIcon: Icon(
              Icons.attach_money_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Initial Quantity',
            prefixIcon: Icon(
              Icons.format_list_numbered_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        // onPressed: _isUploading ? null : _submitForm,
        onPressed: () async {
          await HapticFeedbackHelper.selectionClick();
          _isUploading ? null : _submitForm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        child: Text(
          'Save Product',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final productData = {
        'name': _nameController.text,
        'base_price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'description': _descController.text,
        'product_type_id': 1,
        'category_id': 1,
        'attributes': [
          {'attribute_id': 1, 'value': 'Blue'},
          {'attribute_id': 2, 'value': '64'},
          {'attribute_id': 7, 'value': 10},
          {'attribute_id': 9, 'value': 7},
        ]
      };

      final productCubit = context.read<ProductCubit>();
      final product = await productCubit.addProduct(productData);

      if (_imageFile != null && product.id != null) {
        await productCubit.uploadProductImage(product.id!, _imageFile!);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    super.dispose();
  }
}



// // lib/pages/product_form.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../controllers/product_controller.dart';
//
// class ProductForm extends StatefulWidget {
//   const ProductForm({Key? key}) : super(key: key);
//
//   @override
//   State<ProductForm> createState() => _ProductFormState();
// }
//
// class _ProductFormState extends State<ProductForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _quantityController = TextEditingController();
//   final _descController = TextEditingController();
//   File? _imageFile;
//   final _picker = ImagePicker();
//   bool _isUploading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Product'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _isUploading ? null : _submitForm,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     _buildImagePicker(),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Product Name',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) => value!.isEmpty ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _priceController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Price',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) => value!.isEmpty ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _quantityController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Initial Quantity',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) => value!.isEmpty ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _descController,
//                       maxLines: 3,
//                       decoration: const InputDecoration(
//                         labelText: 'Description',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _isUploading ? null : _submitForm,
//                       child: const Text('Save Product'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (_isUploading)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImagePicker() {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         height: 200,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: _imageFile != null
//             ? ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.file(_imageFile!, fit: BoxFit.cover),
//         )
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.add_a_photo, size: 50),
//             SizedBox(height: 8),
//             Text('Add Product Image'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isUploading = true);
//
//     try {
//       final productData = {
//         'name': _nameController.text,
//         'base_price': double.parse(_priceController.text),
//         'quantity': int.parse(_quantityController.text),
//         'description': _descController.text,
//         'product_type_id':1,
//         'category_id':1,
//         'attributes':[
//           {'attribute_id':1,'value':'Blue'},
//           {'attribute_id':2,'value':'64'},
//           {'attribute_id':7,'value':10},
//           {'attribute_id':9,'value':7},
//         ]
//       };
//
//       final productCubit = context.read<ProductCubit>();
//       final product = await productCubit.addProduct(productData);
//
//         print('PRODUCT: ${product.id}');
//       if (_imageFile != null && product.id != null) {
//         await productCubit.uploadProductImage(product.id!, _imageFile!);
//       }
//
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isUploading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     _quantityController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }
// }
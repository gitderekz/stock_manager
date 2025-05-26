// // lib/pages/search_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../controllers/product_controller.dart';
//
// class SearchPage extends StatelessWidget {
//   const SearchPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           decoration: InputDecoration(
//             hintText: 'Search products...',
//             border: InputBorder.none,
//           ),
//           onChanged: (query) {
//             context.read<ProductCubit>().searchProducts(query);
//           },
//         ),
//       ),
//       body: BlocBuilder<ProductCubit, ProductState>(
//         builder: (context, state) {
//           if (state is ProductLoading) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (state is ProductSearchResults) {
//             return ListView.builder(
//               itemCount: state.results.length,
//               itemBuilder: (context, index) {
//                 final product = state.results[index];
//                 return ListTile(
//                   title: Text(product.name),
//                   subtitle: Text('Stock: ${product.quantity}'),
//                   onTap: () {
//                     // Navigate to product details
//                   },
//                 );
//               },
//             );
//           }
//
//           return Center(child: Text('Enter search terms'));
//         },
//       ),
//     );
//   }
// }
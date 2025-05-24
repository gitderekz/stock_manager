// controllers/product_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/config/env.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';
import '../utils/auth_helper.dart';
import '../utils/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class ProductCubit extends Cubit<ProductState> {
  final DatabaseHelper dbHelper;
  static String get baseUrl => Env.baseUrl;

  ProductCubit(this.dbHelper) : super(ProductLoading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await dbHelper.getProducts();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> addStockMovement(StockMovement movement) async {
    try {
      await dbHelper.addStockMovement(movement);
      await dbHelper.addToSyncQueue('stock_movements', movement.id, 'create', movement.toMap());
      loadProducts(); // Refresh the product list
    } catch (e) {
      emit(ProductError('Failed to add movement: ${e.toString()}'));
    }
  }
  // Future<void> fetchDashboardStats() async {
  // final token = await AuthHelper.getToken();
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/dashboard/stats'),
  //     headers: {
  //           'Authorization': 'Bearer $token',
  //           'Content-Type': 'application/json',
  //         },
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       emit(ProductLoaded(
  //         products: state.products,
  //         stats: data,
  //       ));
  //     }
  //   } catch (e) {
  //     emit(ProductError('Failed to load stats: ${e.toString()}'));
  //   }
  // }
  // Update fetchDashboardStats to use proper state
  Future<void> fetchDashboardStats() async {
    try {
      final token = await AuthHelper.getToken();
      final response = await http.get(Uri.parse('$baseUrl/products/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DATA: ${data}');
        final stats = data['stats'];
        emit(ProductLoaded(
          products: (state is ProductLoaded) ? (state as ProductLoaded).products : [],
          stats: stats,
          recentMovements: (state is ProductLoaded) ? (state as ProductLoaded).recentMovements : [],
        ));

        // final data = json.decode(response.body);
        // if (state is ProductLoaded) {
        //   emit(ProductLoaded(
        //     products: (state as ProductLoaded).products,
        //     stats: data,
        //     recentMovements: (state as ProductLoaded).recentMovements,
        //   ));
        // } else {
        //   emit(ProductLoaded(
        //     products: const [],
        //     stats: data,
        //   ));
        // }
      }
    } catch (e) {
      emit(ProductError('Failed to load stats: ${e.toString()}'));
    }
  }

  Future<Product> addProduct(Map<String, dynamic> productData) async {
    try {
      final token = await AuthHelper.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(productData),
      );

      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final newProduct = Product.fromJson(decoded['product']);
        // final newProduct = Product.fromMap(decoded['product']);

        emit(ProductLoaded(
          products: [...state.products, newProduct],
        ));
        return newProduct; // Return the product
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      emit(ProductError('Failed to add product: ${e.toString()}'));
      print('${e.toString()}');
      rethrow;
    }
  }


  Future<void> uploadProductImage(int productId, File imageFile) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) throw Exception('Not authenticated');

      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('Selected file is not a valid image');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products/$productId/image'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType), // ← this is key!
      ));

      final response = await request.send();

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw Exception('Failed to upload image: $body');
      }

      await fetchProducts();
    } catch (e) {
      emit(ProductError('Failed to upload image: ${e.toString()}'));
      rethrow;
    }
  }


  Future<void> fetchProducts() async {
    print('REFRESH');
    try {
      final token = await AuthHelper.getToken();
      final response = await http.get(Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('REFRESH 2 ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products = data.map((json) => Product.fromJson(json)).toList();
        // final List<dynamic> data = json.decode(response.body);
        // final products = data
        //     .where((item) => item['dataValues'] != null)
        //     .map((item) => Product.fromJson(item['dataValues']))
        //     .toList();

        print('FETCH 01: ${products.length.toString()}');
        print('FETCH: ${data.toString()}');
        emit(ProductLoaded(products: products));
      }
    } catch (e) {
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }

}


abstract class ProductState {
  List<Product> get products => []; // Add base getter
}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<StockMovement> recentMovements;
  final Map<String, dynamic>? stats;  // Add stats field


  ProductLoaded({
    required this.products,
    this.recentMovements = const [],
    this.stats,
  });
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
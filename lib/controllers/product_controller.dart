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
    // First load from local DB
    loadProducts().then((_) {
      // Then try to fetch from server
      Future.microtask(() => fetchProducts());
    });
  }

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await dbHelper.getProducts();
      print("PRODUCTS: ${products}");
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
        final stats = data['stats'];
        final recent = (data['recentMovements'] as List)
            .map((json) => StockMovement.fromJson(json))
            .toList();
print('ALL-STATS: ${stats['salesTrend']}');
        emit(ProductLoaded(
          products: state is ProductLoaded ? (state as ProductLoaded).products : [],
          stats: stats,
          // salesTrend: data['stats']['salesTrend'] ?? [],
          recentMovements: recent,
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
    try {
      final token = await AuthHelper.getToken();
      final response = await http.get(Uri.parse('$baseUrl/products'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products = data.map((json) => Product.fromJson(json)).toList();

        emit(ProductLoaded(
          products: products,
          stats: state is ProductLoaded ? (state as ProductLoaded).stats : null,
          recentMovements: state is ProductLoaded ? (state as ProductLoaded).recentMovements : [],
        ));
      }
    } catch (e) {
      // Don't override the UI with an error if it already has data
      if (state is! ProductLoaded) {
        emit(ProductError('Failed to load products: ${e.toString()}'));
      }
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final token = await AuthHelper.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Remove from local state
        if (state is ProductLoaded) {
          final currentState = state as ProductLoaded;
          emit(ProductLoaded(
            products: currentState.products.where((p) => p.id != productId).toList(),
            stats: currentState.stats,
            recentMovements: currentState.recentMovements,
          ));
        }
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      emit(ProductError('Failed to delete product: ${e.toString()}'));
      rethrow;
    }
  }

}


abstract class ProductState {
  List<Product> get products => []; // Add base getter
}

class ProductLoading extends ProductState {
  @override
  List<Product> get products => [];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final Map<String, dynamic>? stats;  // Add stats field
  final List<StockMovement> recentMovements;
  final List<dynamic> salesTrend;


  ProductLoaded({
    required this.products,
    this.stats,
    this.recentMovements = const [],
    this.salesTrend = const [],
  });
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
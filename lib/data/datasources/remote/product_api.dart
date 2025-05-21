import 'package:dio/dio.dart';
import 'package:stock_manager/domain/entities/product.dart';

class ProductApi {
  final Dio dio;

  ProductApi(this.dio);

  Future<List<Product>> getProducts() async {
    try {
      final response = await dio.get('/products');
      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await dio.post('/products', data: product.toJson());
      return Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create product');
    }
  }

// Implement other API methods
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await dio.put('/products/${product.id}', data: product.toJson());
      return Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update product');
    }
  }
  Future<void> deleteProduct(int id) async {
    try {
      await dio.delete('/products/$id');
    } catch (e) {
      throw Exception('Failed to delete product');
    }
  }

}
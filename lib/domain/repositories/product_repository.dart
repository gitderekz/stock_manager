import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/domain/exceptions/sync_exceptions.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({bool isSync = false});
  Future<Product> createProduct(Product product, {bool isSync = false});
  Future<Product> updateProduct(Product product, {bool isSync = false});
  Future<void> deleteProduct(int id, {bool isSync = false});
}
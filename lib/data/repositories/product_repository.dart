import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/domain/repositories/product_repository.dart';
import 'package:stock_manager/data/datasources/remote/product_api.dart';
// import 'package:stock_manager/data/datasources/local/database_helper.dart';
import 'package:stock_manager/domain/exceptions/sync_exceptions.dart';
import 'package:stock_manager/utils/services/connectivity_service.dart';

import '../../utils/helpers/database_helper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApi productApi;
  final DatabaseHelper databaseHelper;
  final ConnectivityService connectivityService;

  ProductRepositoryImpl({
    required this.productApi,
    required this.databaseHelper,
    required this.connectivityService,
  });

  @override
  Future<List<Product>> getProducts({bool isSync = false}) async {
    final isOnline = await connectivityService.isConnected();

    if (isOnline && !isSync) {
      try {
        final products = await productApi.getProducts();
        // Cache products locally
        await databaseHelper.insertProducts(products);
        return products;
      } catch (e) {
        // Fallback to local data if online fails
        return await databaseHelper.getProducts();
      }
    } else {
      return await databaseHelper.getProducts();
    }
  }

  @override
  Future<Product> createProduct(Product product, {bool isSync = false}) async {
    final isOnline = await connectivityService.isConnected();

    if (isOnline || isSync) {
      try {
        final createdProduct = await productApi.createProduct(product);
        await databaseHelper.insertProduct(createdProduct);
        return createdProduct;
      } catch (e) {
        if (!isSync) {
          throw OfflineOperationException();
        }
        rethrow;
      }
    } else {
      // Add to sync queue
      await databaseHelper.addToSyncQueue(
        tableName: 'products',
        operation: 'create',
        data: product.toJson(),
      );
      throw OfflineOperationException();
    }
  }

// Implement other CRUD operations similarly
  @override
  Future<Product> updateProduct(Product product, {bool isSync = false}) async {
    final isOnline = await connectivityService.isConnected();

    if (isOnline || isSync) {
      try {
        final updatedProduct = await productApi.updateProduct(product);
        await databaseHelper.updateProduct(updatedProduct);
        return updatedProduct;
      } catch (e) {
        if (!isSync) {
          throw OfflineOperationException();
        }
        rethrow;
      }
    } else {
      await databaseHelper.addToSyncQueue(
        tableName: 'products',
        operation: 'update',
        data: product.toJson(),
      );
      throw OfflineOperationException();
    }
  }

  @override
  Future<void> deleteProduct(int id, {bool isSync = false}) async {
    final isOnline = await connectivityService.isConnected();

    if (isOnline || isSync) {
      try {
        await productApi.deleteProduct(id);
        await databaseHelper.deleteProduct(id);
      } catch (e) {
        if (!isSync) {
          throw OfflineOperationException();
        }
        rethrow;
      }
    } else {
      await databaseHelper.addToSyncQueue(
        tableName: 'products',
        operation: 'delete',
        data: {'id': id},
      );
      throw OfflineOperationException();
    }
  }

}
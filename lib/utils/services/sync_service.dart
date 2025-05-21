import 'package:stock_manager/domain/entities/sync_queue_item.dart';
import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/domain/entities/stock_movement.dart';
import 'package:stock_manager/domain/repositories/product_repository.dart';
import 'package:stock_manager/domain/repositories/inventory_repository.dart';
import 'package:stock_manager/domain/repositories/sync_repository.dart';
import 'package:stock_manager/utils/services/connectivity_service.dart';

class SyncService {
  final ConnectivityService _connectivityService;
  final SyncRepository _syncRepository;
  final ProductRepository _productRepository;
  final InventoryRepository _inventoryRepository;

  SyncService({
    required ConnectivityService connectivityService,
    required SyncRepository syncRepository,
    required ProductRepository productRepository,
    required InventoryRepository inventoryRepository,
  })  : _connectivityService = connectivityService,
        _syncRepository = syncRepository,
        _productRepository = productRepository,
        _inventoryRepository = inventoryRepository;

  Future<void> syncData() async {
    final isOnline = await _connectivityService.isConnected();
    if (!isOnline) return;

    final pendingItems = await _syncRepository.getPendingSyncItems();

    for (final item in pendingItems) {
      try {
        switch (item.tableName) {
          case 'products':
            await _handleProductSync(item);
            break;
          case 'inventory':
            await _handleInventorySync(item);
            break;
        }
        await _syncRepository.markAsSynced(item.id);
      } catch (e) {
        continue;
      }
    }
  }

  Future<void> _handleProductSync(SyncQueueItem item) async {
    final product = Product.fromJson(item.data);

    switch (item.operation) {
      case 'create':
        await _productRepository.createProduct(product, isSync: true);
        break;
      case 'update':
        await _productRepository.updateProduct(product, isSync: true); // See method signature!
        break;
      case 'delete':
        await _productRepository.deleteProduct(item.recordId, isSync: true);
        break;
    }
  }

  Future<void> _handleInventorySync(SyncQueueItem item) async {
    switch (item.operation) {
      case 'create':
        await _inventoryRepository.addStockMovement(
          StockMovement.fromJson(item.data),
        );
        break;
      case 'update':
        await _inventoryRepository.updateInventory(
          item.recordId,
          item.data['quantity'],
        );
        break;
    }
  }
}




// import 'package:stock_manager/domain/entities/sync_queue_item.dart';
// import 'package:stock_manager/domain/repositories/product_repository.dart';
// import 'package:stock_manager/domain/repositories/inventory_repository.dart';
// import 'package:stock_manager/domain/repositories/sync_repository.dart';
// import 'package:stock_manager/utils/services/connectivity_service.dart';
// import 'package:stock_manager/domain/entities/product.dart';
// import 'package:stock_manager/domain/entities/stock_movement.dart';
//
// class SyncService {
//   final ConnectivityService _connectivityService;
//   final SyncRepository _syncRepository;
//   final ProductRepository _productRepository;
//   final InventoryRepository _inventoryRepository;
//
//   SyncService({
//     required ConnectivityService connectivityService,
//     required SyncRepository syncRepository,
//     required ProductRepository productRepository,
//     required InventoryRepository inventoryRepository,
//   })  : _connectivityService = connectivityService,
//         _syncRepository = syncRepository,
//         _productRepository = productRepository,
//         _inventoryRepository = inventoryRepository;
//
//   Future<void> syncData() async {
//     final isOnline = await _connectivityService.isConnected();
//     if (!isOnline) return;
//
//     final pendingItems = await _syncRepository.getPendingSyncItems();
//
//     for (final item in pendingItems) {
//       try {
//         switch (item.tableName) {
//           case 'products':
//             await _handleProductSync(item);
//             break;
//           case 'inventory':
//             await _handleInventorySync(item);
//             break;
//         }
//         await _syncRepository.markAsSynced(item.id);
//       } catch (e) {
//         continue;
//       }
//     }
//   }
//
//   Future<void> _handleProductSync(SyncQueueItem item) async {
//     switch (item.operation) {
//       case 'create':
//         await _productRepository.createProduct(
//           Product.fromJson(item.data),
//           isSync: true,
//         );
//         break;
//       case 'update':
//         // await _productRepository.updateProduct(
//         //   item.recordId,
//         //   Product.fromJson(item.data),
//         //   isSync: true,
//         // );
//         await _productRepository.updateProduct(
//           Product.fromJson(item.data),
//           isSync: true,
//         );
//         break;
//       case 'delete':
//         await _productRepository.deleteProduct(item.recordId, isSync: true);
//         break;
//     }
//   }
//
//   Future<void> _handleInventorySync(SyncQueueItem item) async {
//     switch (item.operation) {
//       case 'create':
//         await _inventoryRepository.addStockMovement(
//           StockMovement.fromJson(item.data),
//         );
//         break;
//       case 'update':
//         await _inventoryRepository.updateInventory(
//           item.recordId,
//           item.data['quantity'],
//         );
//         break;
//     }
//   }
// }
// // *******************************************************


// import 'package:stock_manager/data/repositories/product_repository.dart';
// import 'package:stock_manager/data/repositories/inventory_repository.dart';
// import 'package:stock_manager/data/repositories/sync_repository.dart';
// import 'package:stock_manager/utils/services/connectivity_service.dart';
//
// import '../../domain/entities/sync_queue_item.dart';
// import '../../domain/repositories/sync_repository.dart';
//
// class SyncService {
//   final ConnectivityService _connectivityService;
//   final SyncRepository _syncRepository;
//   final ProductRepository _productRepository;
//   final InventoryRepository _inventoryRepository;
//
//   SyncService({
//     required ConnectivityService connectivityService,
//     required SyncRepository syncRepository,
//     required ProductRepository productRepository,
//     required InventoryRepository inventoryRepository,
//   })  : _connectivityService = connectivityService,
//         _syncRepository = syncRepository,
//         _productRepository = productRepository,
//         _inventoryRepository = inventoryRepository;
//
//   Future<void> syncData() async {
//     final isOnline = await _connectivityService.isConnected();
//     if (!isOnline) return;
//
//     // Get pending sync items
//     final pendingItems = await _syncRepository.getPendingSyncItems();
//
//     for (final item in pendingItems) {
//       try {
//         switch (item.tableName) {
//           case 'products':
//             await _handleProductSync(item);
//             break;
//           case 'inventory':
//             await _handleInventorySync(item);
//             break;
//         // Handle other tables...
//         }
//
//         // Mark as synced
//         await _syncRepository.markAsSynced(item.id);
//       } catch (e) {
//         // Log error and continue with next item
//         continue;
//       }
//     }
//   }
//
//   Future<void> _handleProductSync(SyncQueueItem item) async {
//     switch (item.operation) {
//       case 'create':
//         await _productRepository.createProduct(item.data, isSync: true);
//         break;
//       case 'update':
//         await _productRepository.updateProduct(item.recordId, item.data, isSync: true);
//         break;
//       case 'delete':
//         await _productRepository.deleteProduct(item.recordId, isSync: true);
//         break;
//     }
//   }
//
//   Future<void> _handleInventorySync(SyncQueueItem item) async {
//     switch (item.operation) {
//       case 'create':
//         await _inventoryRepository.createInventory(item.data, isSync: true);
//         break;
//       case 'update':
//         await _inventoryRepository.updateInventory(item.recordId, item.data, isSync: true);
//         break;
//     }
//   }
//
//   Future<void> syncOnResume() async {
//     await syncData();
//   }
//
//   Future<void> periodicSync() async {
//     await syncData();
//   }
// }
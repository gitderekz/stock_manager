import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 1)
class SyncQueueItem {
  @HiveField(0)
  final String tableName;

  @HiveField(1)
  final int recordId;

  @HiveField(2)
  final String operation;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int id;

  SyncQueueItem({
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.data,
    required this.createdAt,
    required this.id,
  });
}

class SyncResult {
  final int syncedItems;

  SyncResult({required this.syncedItems});
}




// import 'package:hive/hive.dart';
//
// part 'sync_queue_item.g.dart';
//
// @HiveType(typeId: 1)
// class SyncQueueItem {
//   @HiveField(0)
//   final String tableName;
//
//   @HiveField(1)
//   final int recordId;
//
//   @HiveField(2)
//   final String operation;
//
//   @HiveField(3)
//   final Map<String, dynamic> data;
//
//   @HiveField(4)
//   final DateTime createdAt;
//
//   SyncQueueItem({
//     required this.tableName,
//     required this.recordId,
//     required this.operation,
//     required this.data,
//     required this.createdAt,
//   });
// }
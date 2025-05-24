// utils/sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class SyncService {
  final DatabaseHelper dbHelper;
  final String apiUrl;

  SyncService({required this.dbHelper, required this.apiUrl});

  Future<void> syncData() async {
    final pendingItems = await dbHelper.getPendingSyncItems();

    for (final item in pendingItems) {
      try {
        final response = await _sendDataToServer(item);

        if (response.statusCode == 200) {
          await dbHelper.markAsSynced(item['id'] as int);
        }
      } catch (e) {
        print('Sync failed for item ${item['id']}: $e');
      }
    }
  }

  Future<http.Response> _sendDataToServer(Map<String, dynamic> item) async {
    final url = Uri.parse('$apiUrl/${item['table_name']}');
    final data = jsonDecode(item['data'] as String);

    switch (item['operation']) {
      case 'create':
        return await http.post(url, body: data);
      case 'update':
        return await http.put(url, body: data);
      case 'delete':
        return await http.delete(url);
      default:
        throw Exception('Unknown operation: ${item['operation']}');
    }
  }
}
// utils/sync_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stock_manager/utils/api_service.dart';
import 'database_helper.dart';

class SyncService {
  final DatabaseHelper dbHelper;
  final String apiUrl;

  // final DatabaseHelper dbHelper;
  // SyncService(this.dbHelper);

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



  Future<bool> syncAllData(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Synchronizing data...'),
            ],
          ),
        ),
      );

      // Sync pending items
      await _syncPendingItems();

      // Close dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data synchronized successfully')),
      );
      return true;
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: ${e.toString()}')),
      );
      return false;
    }
  }

  Future<void> _syncPendingItems() async {
    final pendingItems = await dbHelper.getPendingSyncItems();

    for (final item in pendingItems) {
      print('PAYLOAD: ${item}');
      try {
        final dataMap = jsonDecode(item['data']); // Now this works perfectly 🎯

        final response = await ApiService.post(
          'stock-movements',
          {
            'table': item['table_name'],
            'operation': item['operation'],
            'data': dataMap, // ✅ Properly structured JSON
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await dbHelper.markAsSynced(item['id'] as int);
        } else {
          print("FAILED TO SYNC (status ${response.statusCode}): ${response.body}");
        }
      } catch (e) {
        print('❌ Failed to sync item ${item['id']}: $e');
      }
    }
  }

}
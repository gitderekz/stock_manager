// lib/utils/socket_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:stock_manager/utils/auth_helper.dart';
import '../config/env.dart';
import '../controllers/product_controller.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket _socket;
  bool _isConnected = false;
  final List<String> _logMessages = [];

  factory SocketService() => _instance;

  SocketService._internal();

  List<String> get logMessages => _logMessages;
  bool get isConnected => _isConnected;

  void initialize(BuildContext context) {
    _socket = io.io(Env.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    _socket.onConnect((_) {
      _isConnected = true;
      _addLog('Socket connected');
      _authenticate();
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      _addLog('Socket disconnected');
    });

    _socket.onConnectError((err) => _addLog('Connection error: $err'));
    _socket.onError((err) => _addLog('Socket error: $err'));
    _socket.onReconnect((_) => _addLog('Reconnecting...'));
    _socket.onReconnectAttempt((attempt) => _addLog('Reconnect attempt $attempt'));
    _socket.onReconnectError((err) => _addLog('Reconnect error: $err'));

    _socket.on('stock_update', (data) {
      _addLog('Stock update received');
      context.read<ProductCubit>().fetchProducts();
    });

    _socket.on('notification', (data) {
      _addLog('New notification: ${data['message']}');
      // Handle notification
    });
  }

  Future<void> _authenticate() async {
    // Get token from your auth system
    final token = await AuthHelper.getToken();
    _socket.emit('authenticate', token);
    _addLog('Authentication sent');
  }

  void _addLog(String message) {
    _logMessages.add('${DateTime.now()}: $message');
    if (_logMessages.length > 100) _logMessages.removeAt(0);
    debugPrint(message);
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
    _logMessages.clear();
  }
}
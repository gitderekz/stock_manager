// utils/database_helper.dart
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';

class DatabaseHelper {
  static const _databaseName = 'stock_manager.db';
  static const _databaseVersion = 1;

  static const productsTable = 'products';
  static const movementsTable = 'stock_movements';
  static const syncQueueTable = 'sync_queue';
  static const usersTable = 'users';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
      await db.execute('''
        CREATE TABLE $usersTable (
          id INTEGER PRIMARY KEY,
          username TEXT NOT NULL,
          full_name TEXT,
          email TEXT,
          role TEXT NOT NULL,
          password_hash TEXT NOT NULL,
          language_preference TEXT,
          theme_preference TEXT,
          is_active INTEGER DEFAULT 1,
          token TEXT
        )
      '''
      );

    // Products table
    await db.execute('''
      CREATE TABLE $productsTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        base_price REAL NOT NULL,
        description TEXT,
        quantity INTEGER NOT NULL,
        low_stock_threshold INTEGER NOT NULL,
        product_type_id INTEGER,
        category_id INTEGER,
        is_active INTEGER DEFAULT 1,
        last_updated TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Stock movements table
    await db.execute('''
      CREATE TABLE $movementsTable (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        reference TEXT,
        notes TEXT,
        user_id INTEGER NOT NULL,
        movement_date TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES $productsTable (id)
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE $syncQueueTable (
        id INTEGER PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_timestamp TEXT
      )
    ''');
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(usersTable, {
      // 'id': userData['user']['id'],
      'username': userData['user']['username'],
      'full_name': userData['user']['full_name'],
      'email': userData['user']['email'],
      'role': userData['user']['role'],
      'password_hash': userData['user']['passwordHash'],
      'language_preference': userData['user']['language_preference'],
      'theme_preference': userData['user']['theme_preference'],
      'is_active': userData['user']['is_active'] ? 1 : 0,
      'token': userData['token'],
    });
  }

  // Product CRUD operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(productsTable, product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(productsTable);
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // Stock movement operations
  Future<int> addStockMovement(StockMovement movement) async {
    final db = await database;
    return await db.insert(movementsTable, movement.toMap());
  }

  Future<List<StockMovement>> getStockMovements() async {
    final db = await database;
    final maps = await db.query(DatabaseHelper.movementsTable);

    return maps.map((map) => StockMovement.fromMap(map)).toList();
  }


  // Sync queue operations
  Future<int> addToSyncQueue(String table, int id, String operation, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(syncQueueTable, {
      'table_name': table,
      'record_id': id,
      'operation': operation,
      // 'data': data.toString(),
      'data': jsonEncode(data),
      'is_synced': 0
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query(syncQueueTable, where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      syncQueueTable,
      {'is_synced': 1, 'sync_timestamp': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
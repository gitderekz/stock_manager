import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/domain/entities/sync_queue_item.dart';

class DatabaseHelper {
  static const String _databaseName = 'stock_manager.db';
  static const int _databaseVersion = 1;

  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._internal();
  // Factory constructor
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        product_type_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        base_price REAL NOT NULL,
        description TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        low_stock_threshold INTEGER DEFAULT 5,
        last_updated TEXT,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        reference TEXT,
        notes TEXT,
        user_id INTEGER NOT NULL,
        movement_date TEXT,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_timestamp TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < 2) {
      // Example upgrade for version 2
      // await db.execute('ALTER TABLE products ADD COLUMN new_column TEXT');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
        String? orderBy,
      }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(
      String table,
      Map<String, dynamic> data, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> executeSql(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }
  // ****************************

  Future<void> insertProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    for (final product in products) {
      batch.insert(
        'products',
        _productToMap(product),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return List.generate(maps.length, (i) => _productFromMap(maps[i]));
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      _productToMap(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      _productToMap(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addToSyncQueue({
    required String tableName,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'operation': operation,
      'data': jsonEncode(data), //data.toString(),
      'created_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'product_type_id': product.productTypeId,
      'category_id': product.categoryId,
      'base_price': product.basePrice,
      'description': product.description,
      'is_active': product.isActive ? 1 : 0,
      'created_at': product.createdAt.toIso8601String(),
      'updated_at': product.updatedAt.toIso8601String(),
      'is_synced': 0,
    };
  }

  Product _productFromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      productTypeId: map['product_type_id'],
      categoryId: map['category_id'],
      quantity: map['quantity'],
      basePrice: map['base_price'],
      description: map['description'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

}
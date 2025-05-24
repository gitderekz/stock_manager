// utils/database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/product.dart';

class AppDatabase {
  static Database? _db;

  static Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'stock_manager.db'),
      onCreate: (db, version) async {
        return db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY,
            name TEXT,
            quantity INTEGER,
            threshold INTEGER,
            image TEXT,
            barcode TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  static Database get instance => _db!;

  static Future<void> insertProduct(Product product) async {
    await _db!.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Product>> getProducts() async {
    final maps = await _db!.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  static Future<void> updateStock(int id, int quantity) async {
    await _db!.rawUpdate(
      'UPDATE products SET quantity = ? WHERE id = ?',
      [quantity, id],
    );
  }

  static Future<void> deleteProduct(int id) async {
    await _db!.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
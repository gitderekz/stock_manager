// models/product.dart
class Product {
  final int id;
  final String name;
  final double basePrice;
  final String? description;
  final int quantity;
  final int lowStockThreshold;
  final int? productTypeId;
  final int? categoryId;
  final bool isActive;
  final DateTime? lastUpdated;
  final bool isSynced;
  final String? imageUrl; // Add image support

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    this.description,
    required this.quantity,
    this.lowStockThreshold = 5,
    this.productTypeId,
    this.categoryId,
    this.isActive = true,
    this.lastUpdated,
    this.isSynced = false,
    this.imageUrl,
  });

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'description': description,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'productTypeId': productTypeId,
      'categoryId': categoryId,
      'isActive': isActive,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isSynced': isSynced,
      'imageUrl': imageUrl,
    };
  }

  // Add fromJson factory
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      basePrice: double.parse(json['base_price']),
      description: json['description'],
      quantity: json['quantity'],
      lowStockThreshold: json['low_stock_threshold'] ?? 5,
      productTypeId: json['product_type_id'],
      categoryId: json['category_id'],
      isActive: json['is_active'] ?? true,
      lastUpdated: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isSynced: json['is_synced'] ?? false,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_price': basePrice,
      'description': description,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'product_type_id': productTypeId,
      'category_id': categoryId,
      'is_active': isActive ? 1 : 0,
      'last_updated': lastUpdated?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'image_url': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      basePrice: map['base_price'],
      description: map['description'],
      quantity: map['quantity'],
      lowStockThreshold: map['low_stock_threshold'] ?? 5,
      productTypeId: map['product_type_id'],
      categoryId: map['category_id'],
      isActive: map['is_active'] == 1,
      lastUpdated: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      isSynced: map['is_synced'] == 1,
      imageUrl: map['image_url'],
    );
  }
}
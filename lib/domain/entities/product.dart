// class Product {
//   final int id;
//   final String name;
//   final String description;
//   final double price;
//   final int stock;
//
//   Product({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.stock,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'] ?? '',
//       price: json['price'].toDouble(),
//       stock: json['stock'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'price': price,
//       'stock': stock,
//     };
//   }
// }

class Product {
  final int id;
  final String name;
  final int productTypeId;
  final int categoryId;
  final double basePrice;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int quantity; // Added for stock management
  final int lowStockThreshold; // Added for alerts
  final String? imageUrl; // Added for product images

  Product({
    required this.id,
    required this.name,
    required this.productTypeId,
    required this.categoryId,
    required this.basePrice,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.quantity, // Added
    this.lowStockThreshold = 5, // Default threshold
    this.imageUrl, // Added
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      productTypeId: json['productTypeId'],
      categoryId: json['categoryId'],
      basePrice: json['basePrice'].toDouble(),
      description: json['description'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      quantity: json['quantity'] ?? 0, // Added
      lowStockThreshold: json['lowStockThreshold'] ?? 5, // Added
      imageUrl: json['imageUrl'], // Added
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'productTypeId': productTypeId,
      'categoryId': categoryId,
      'basePrice': basePrice,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'quantity': quantity, // Added
      'lowStockThreshold': lowStockThreshold, // Added
      'imageUrl': imageUrl, // Added
    };
  }
}
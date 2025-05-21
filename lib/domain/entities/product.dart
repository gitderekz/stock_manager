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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      productTypeId: json['productTypeId'],
      categoryId: json['categoryId'],
      basePrice: json['basePrice'].toDouble(),
      description: json['description'] ?? '',
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
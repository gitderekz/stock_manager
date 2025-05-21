import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/data/models/product_model.dart';

class ProductAdapter {
  static Product fromModel(ProductModel model) {
    return Product(
      id: model.id,
      name: model.name,
      productTypeId: model.productTypeId,
      categoryId: model.categoryId,
      basePrice: model.basePrice,
      description: model.description,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static ProductModel toModel(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      productTypeId: entity.productTypeId,
      categoryId: entity.categoryId,
      basePrice: entity.basePrice,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static Product fromJson(Map<String, dynamic> json) {
    return ProductModel.fromJson(json);
  }

  static Map<String, dynamic> toJson(Product product) {
    return ProductModel.fromEntity(product).toJson();
  }
}
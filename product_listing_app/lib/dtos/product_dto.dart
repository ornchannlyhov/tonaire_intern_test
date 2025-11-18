import 'package:product_listing_app/models/product.dart';

class ProductDto {
  final int? id;
  final String productName;
  final double price;
  final int stock;

  ProductDto({
    this.id,
    required this.productName,
    required this.price,
    required this.stock,
  });

  // Convert DTO to Model
  Product toModel() {
    return Product(
      id: id ?? 0,
      productName: productName,
      price: price,
      stock: stock,
    );
  }

  // Convert Model to DTO
  factory ProductDto.fromModel(Product product) {
    return ProductDto(
      id: product.id,
      productName: product.productName,
      price: product.price,
      stock: product.stock,
    );
  }

  // From JSON
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int?,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productName': productName,
      'price': price,
      'stock': stock,
    };
  }
}

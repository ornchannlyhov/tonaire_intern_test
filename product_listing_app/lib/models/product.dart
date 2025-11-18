class Product {
  final int id;
  final String productName;
  final double price;
  final int stock;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.stock,
  });

  Product copyWith({int? id, String? productName, double? price, int? stock}) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}

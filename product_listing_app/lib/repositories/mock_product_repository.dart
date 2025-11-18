import 'dart:async';
import 'product_repository.dart';
import '../dtos/product_dto.dart';

class MockProductRepository extends ProductRepository {
  final List<ProductDto> _products = List.generate(
    5,
    (index) => ProductDto(
      id: index + 1,
      productName: 'Product ${index + 1}',
      price: (index + 1) * 10.0,
      stock: (index + 1) * 5,
    ),
  );

  @override
  Future<ProductDto> createProduct(ProductDto product) async {
    final newProduct = ProductDto(
      id: _products.length + 1,
      productName: product.productName,
      price: product.price,
      stock: product.stock,
    );
    _products.add(newProduct);
    await Future.delayed(Duration(milliseconds: 300));
    return newProduct;
  }

  @override
  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
    await Future.delayed(Duration(milliseconds: 200));
  }

  @override
  Future<List<ProductDto>> fetchProducts() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _products;
  }

  @override
  Future<ProductDto?> fetchProductById(int id) async {
    await Future.delayed(Duration(milliseconds: 200));
    return _products.firstWhere(
      (p) => p.id == id,
      // ignore: cast_from_null_always_fails
      orElse: () => null as ProductDto,
    );
  }

  @override
  Future<ProductDto> updateProduct(ProductDto product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
    await Future.delayed(Duration(milliseconds: 300));
    return product;
  }
}

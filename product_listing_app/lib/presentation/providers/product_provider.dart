import 'package:flutter/foundation.dart';
import 'package:product_listing_app/dtos/product_dto.dart';
import 'package:product_listing_app/models/product.dart';
import 'package:product_listing_app/repositories/product_repository.dart';
import 'package:product_listing_app/utils/asynvalue.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  AsyncValue<List<Product>> _products = const AsyncLoading();
  AsyncValue<List<Product>> get products => _products;

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    _products = const AsyncLoading();
    notifyListeners();

    try {
      final result = await repository.fetchProducts();
      final products = result.map((dto) => dto.toModel()).toList();
      _products = AsyncSuccess(products);
      notifyListeners();
      return products;
    } catch (e) {
      _products = AsyncError(e);
      notifyListeners();
      rethrow;
    }
  }

  // Create a new product
  Future<Product> addProduct(ProductDto productDto) async {
    try {
      final newProductDto = await repository.createProduct(productDto);
      final newProduct = newProductDto.toModel();

      if (_products.hasData) {
        final updatedList = List<Product>.from(_products.data!);
        updatedList.add(newProduct);
        _products = AsyncSuccess(updatedList);
      } else {
        await fetchProducts();
      }

      notifyListeners();
      return newProduct;
    } catch (e) {
      _products = AsyncError(e);
      notifyListeners();
      rethrow;
    }
  }

  // Update a product
  Future<Product> updateProduct(ProductDto productDto) async {
    if (productDto.id == null) {
      final error = 'Product ID is required for update';
      _products = AsyncError(error);
      notifyListeners();
      throw Exception(error);
    }

    try {
      final updatedDto = await repository.updateProduct(productDto);
      final updatedProduct = updatedDto.toModel();

      if (_products.hasData) {
        final updatedList = _products.data!.map((p) {
          return p.id == updatedProduct.id ? updatedProduct : p;
        }).toList();
        _products = AsyncSuccess(updatedList);
      } else {
        await fetchProducts();
      }

      notifyListeners();
      return updatedProduct;
    } catch (e) {
      _products = AsyncError(e);
      notifyListeners();
      rethrow;
    }
  }

  // Delete a product
  Future<int> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);

      if (_products.hasData) {
        final updatedList = _products.data!.where((p) => p.id != id).toList();
        _products = AsyncSuccess(updatedList);
        notifyListeners();
      } else {
        await fetchProducts();
      }

      return id;
    } catch (e) {
      _products = AsyncError(e);
      notifyListeners();
      rethrow;
    }
  }
}

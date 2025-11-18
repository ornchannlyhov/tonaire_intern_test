import '../dtos/product_dto.dart';

abstract class ProductRepository {
  // Fetch all products
  Future<List<ProductDto>> fetchProducts();

  // Fetch a single product by ID
  Future<ProductDto?> fetchProductById(int id);

  // Create a new product
  Future<ProductDto> createProduct(ProductDto product);

  // Update product by ID
  Future<ProductDto> updateProduct(ProductDto product);

  // Delete product by ID
  Future<void> deleteProduct(int id);
}

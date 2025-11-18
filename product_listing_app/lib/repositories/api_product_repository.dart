import 'package:dio/dio.dart';
import 'package:product_listing_app/utils/api_helper.dart';
import 'product_repository.dart';
import '../dtos/product_dto.dart';

class ApiProductRepository extends ProductRepository {
  final ApiHelper apiHelper = ApiHelper.instance;

  ApiProductRepository();

  @override
  Future<List<ProductDto>> fetchProducts() async {
    try {
      final response = await apiHelper.dio.get(
        '/products',
        cancelToken: apiHelper.cancelToken,
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((e) => ProductDto.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request cancelled due to network loss');
      }
      rethrow;
    }
  }

  @override
  Future<ProductDto?> fetchProductById(int id) async {
    try {
      final response = await apiHelper.dio.get(
        '/products/$id',
        cancelToken: apiHelper.cancelToken,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? ProductDto.fromJson(data) : null;
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request cancelled due to network loss');
      }
      rethrow;
    }
  }

  @override
  Future<ProductDto> createProduct(ProductDto product) async {
    try {
      final response = await apiHelper.dio.post(
        '/products',
        data: product.toJson(),
        cancelToken: apiHelper.cancelToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return ProductDto.fromJson(data);
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request cancelled due to network loss');
      }
      rethrow;
    }
  }

  @override
  Future<ProductDto> updateProduct(ProductDto product) async {
    if (product.id == null) {
      throw Exception('Product ID is required for update');
    }

    try {
      final response = await apiHelper.dio.put(
        '/products/${product.id}',
        data: product.toJson(),
        cancelToken: apiHelper.cancelToken,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ProductDto.fromJson(data);
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request cancelled due to network loss');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      final response = await apiHelper.dio.delete(
        '/products/$id',
        cancelToken: apiHelper.cancelToken,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request cancelled due to network loss');
      }
      rethrow;
    }
  }
}

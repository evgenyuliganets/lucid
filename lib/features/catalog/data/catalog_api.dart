import 'package:lucid/features/catalog/data/product_dto.dart';
import 'package:dio/dio.dart';

abstract interface class CatalogApi {
  Future<List<ProductDto>> fetchProducts();
}

final class DemoCatalogApi implements CatalogApi {
  const DemoCatalogApi();

  @override
  Future<List<ProductDto>> fetchProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [
      ProductDto(id: 'starter', name: 'Starter product', price: 24),
      ProductDto(id: 'pro', name: 'Pro product', price: 49),
    ];
  }
}

final class DioCatalogApi implements CatalogApi {
  const DioCatalogApi(this._dio);

  final Dio _dio;

  @override
  Future<List<ProductDto>> fetchProducts() async {
    final response = await _dio.get<List<dynamic>>('/products');
    final body = response.data ?? const [];
    return body
        .whereType<Map<String, Object?>>()
        .map(ProductDto.fromJson)
        .toList(growable: false);
  }
}

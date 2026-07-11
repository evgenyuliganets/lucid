import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/catalog/data/catalog_api.dart';
import 'package:lucid/features/catalog/data/catalog_repository.dart';
import 'package:lucid/features/catalog/data/product_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps transport models to domain models', () async {
    final repository = CatalogRepository(_StubApi());

    final result = await repository.fetchProducts();

    expect(result, isA<Success>());
    final products = (result as Success).value as List;
    expect(products.single.name, 'Test product');
  });

  test('turns transport exceptions into a typed failure', () async {
    final repository = CatalogRepository(_FailingApi());

    final result = await repository.fetchProducts();

    expect(result, isA<FailureResult>());
    expect(
      (result as FailureResult).failure.message,
      'Could not load products',
    );
  });
}

class _StubApi implements CatalogApi {
  @override
  Future<List<ProductDto>> fetchProducts() async {
    return const [ProductDto(id: '1', name: 'Test product', price: 10)];
  }
}

class _FailingApi implements CatalogApi {
  @override
  Future<List<ProductDto>> fetchProducts() => throw Exception('offline');
}

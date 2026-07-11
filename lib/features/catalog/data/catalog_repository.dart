import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/catalog/data/catalog_api.dart';
import 'package:lucid/features/catalog/domain/product.dart';

class CatalogRepository {
  const CatalogRepository(this._api);

  final CatalogApi _api;

  Future<Result<List<Product>>> fetchProducts() async {
    try {
      final products = await _api.fetchProducts();
      return Success(
        products.map((product) => product.toDomain()).toList(growable: false),
      );
    } on Object catch (error) {
      return FailureResult(AppFailure('Could not load products', cause: error));
    }
  }
}

import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/catalog/catalog_providers.dart';
import 'package:lucid/features/catalog/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogControllerProvider =
    AsyncNotifierProvider<CatalogController, List<Product>>(
      CatalogController.new,
    );

class CatalogController extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() => _fetchProducts();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProducts);
  }

  Future<List<Product>> _fetchProducts() async {
    final result = await ref.read(catalogRepositoryProvider).fetchProducts();
    return switch (result) {
      Success<List<Product>>(:final value) => value,
      FailureResult<List<Product>>(:final failure) => throw failure,
    };
  }
}

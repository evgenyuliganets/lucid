import 'package:lucid/features/catalog/data/catalog_api.dart';
import 'package:lucid/features/catalog/data/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogApiProvider = Provider<CatalogApi>((ref) {
  return const DemoCatalogApi();
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(catalogApiProvider));
});

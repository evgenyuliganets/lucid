import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/catalog/domain/product.dart';
import 'package:lucid/features/catalog/presentation/catalog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Product catalog')),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CatalogError(
          message: error.toString(),
          onRetry: ref.read(catalogControllerProvider.notifier).reload,
        ),
        data: (products) => RefreshIndicator(
          onRefresh: ref.read(catalogControllerProvider.notifier).reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _ProductCard(products[index]),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.appColors.surfaceAccent,
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(
          'Ready to connect to a real API',
          style: TextStyle(color: context.appColors.textMuted),
        ),
        trailing: Text('\$${product.price.toStringAsFixed(2)}'),
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

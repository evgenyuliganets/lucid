import 'package:lucid/features/catalog/domain/product.dart';

class ProductDto {
  const ProductDto({required this.id, required this.name, required this.price});

  factory ProductDto.fromJson(Map<String, Object?> json) {
    return ProductDto(
      id: json['id']! as String,
      name: json['name']! as String,
      price: (json['price']! as num).toDouble(),
    );
  }

  final String id;
  final String name;
  final double price;

  Product toDomain() => Product(id: id, name: name, price: price);
}

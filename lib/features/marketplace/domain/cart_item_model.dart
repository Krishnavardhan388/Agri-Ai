import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final double quantityKg;

  const CartItem({
    required this.product,
    required this.quantityKg,
  });

  double get totalPrice => product.pricePerKg * quantityKg;

  CartItem copyWith({
    ProductModel? product,
    double? quantityKg,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantityKg: quantityKg ?? this.quantityKg,
    );
  }
}


import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/marketplace/data/order_repository.dart';
import 'package:agri_ai/features/marketplace/data/product_repository.dart';
import 'package:agri_ai/features/marketplace/domain/cart_item_model.dart';
import 'package:agri_ai/features/marketplace/domain/order_model.dart';
import 'package:agri_ai/features/marketplace/domain/product_model.dart';
import 'package:agri_ai/features/marketplace/state/marketplace_provider.dart';

void main() {
  late ProductRepository productRepo;
  late OrderRepository orderRepo;

  setUp(() {
    productRepo = ProductRepository();
    orderRepo = OrderRepository();
  });

  test('ProductRepository returns catalog and adds farmer harvest produce', () async {
    final initialList = await productRepo.getProducts();
    expect(initialList.length, greaterThanOrEqualTo(4));

    const newCrop = ProductModel(
      id: 'test-chilli-1',
      farmerId: 'farmer-ramesh',
      farmerName: 'Ramesh Farm',
      farmerLocation: 'Warangal',
      title: 'Green Hot Chilli',
      description: 'Spicy fresh organic chillies',
      category: 'Spices',
      pricePerKg: 45.0,
      originalPricePerKg: 60.0,
      availableStockKg: 200.0,
      harvestDate: 'Today',
      isOrganic: true,
    );

    await productRepo.addProduct(newCrop);
    final updatedList = await productRepo.getProducts(query: 'Green Hot Chilli');

    expect(updatedList.length, 1);
    expect(updatedList.first.title, 'Green Hot Chilli');
    expect(updatedList.first.pricePerKg, 45.0);
  });

  test('CartNotifier accurately computes quantities, 15% discount, and totals', () {
    final cartNotifier = CartNotifier();

    const sampleProduct = ProductModel(
      id: 'p1',
      farmerId: 'f1',
      farmerName: 'Farm A',
      farmerLocation: 'Loc',
      title: 'Tomatoes',
      description: 'Desc',
      category: 'Vegetables',
      pricePerKg: 40.0,
      originalPricePerKg: 50.0,
      availableStockKg: 100.0,
      harvestDate: 'Now',
    );

    expect(cartNotifier.state.items.isEmpty, true);
    expect(cartNotifier.state.grandTotal, 0.0);

    // Add 2 kg
    cartNotifier.addToCart(sampleProduct, 2.0);
    expect(cartNotifier.state.items.length, 1);
    expect(cartNotifier.state.totalItemsCount, 2);
    expect(cartNotifier.state.subtotal, 80.0);
    expect(cartNotifier.state.discount, 12.0); // 15% of 80 = 12
    expect(cartNotifier.state.deliveryFee, 40.0);
    expect(cartNotifier.state.platformFee, 15.0);
    expect(cartNotifier.state.grandTotal, 80.0 - 12.0 + 40.0 + 15.0); // 123.0

    // Update quantity to 5 kg
    cartNotifier.updateQuantity('p1', 5.0);
    expect(cartNotifier.state.subtotal, 200.0);

    // Remove item
    cartNotifier.removeFromCart('p1');
    expect(cartNotifier.state.items.isEmpty, true);
  });

  test('OrdersNotifier places order and manages order lifecycle with OTP', () async {
    final ordersNotifier = OrdersNotifier(orderRepo);

    const testProduct = ProductModel(
      id: 'p1',
      farmerId: 'farmer-ramesh',
      farmerName: 'Ramesh Farm',
      farmerLocation: 'Warangal',
      title: 'Tomatoes',
      description: 'Desc',
      category: 'Vegetables',
      pricePerKg: 40.0,
      originalPricePerKg: 50.0,
      availableStockKg: 100.0,
      harvestDate: 'Now',
    );

    final cartItems = [
      const CartItem(product: testProduct, quantityKg: 5.0),
    ];

    final order = await ordersNotifier.placeOrderFromCart(
      items: cartItems,
      totalAmount: 200.0,
      paymentId: 'pay_test_9921',
      customerName: 'Priya Sharma',
      customerPhone: '9876512345',
      deliveryAddress: 'Warangal',
    );

    expect(order.id, startsWith('AGRI-'));
    expect(order.deliveryOtp.length, 4);
    expect(order.status, OrderStatus.pending);

    // Update status to packed
    await ordersNotifier.updateStatus(order.id, OrderStatus.packed);
    final updatedFarmerOrders = await orderRepo.getOrdersForFarmer('farmer-ramesh');
    final packedOrder = updatedFarmerOrders.firstWhere((o) => o.id == order.id);

    expect(packedOrder.status, OrderStatus.packed);
  });
}


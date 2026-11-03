import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_repository.dart';
import '../data/product_repository.dart';
import '../data/razorpay_payment_service.dart';
import '../domain/cart_item_model.dart';
import '../domain/order_model.dart';
import '../domain/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final razorpayServiceProvider = Provider<RazorpayPaymentService>((ref) {
  final service = RazorpayPaymentService();
  ref.onDispose(() => service.dispose());
  return service;
});

// --- MARKETPLACE CATALOG NOTIFIER ---
class MarketplaceState {
  final List<ProductModel> products;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;

  const MarketplaceState({
    this.products = const [],
    this.selectedCategory = 'All Items',
    this.searchQuery = '',
    this.isLoading = false,
  });

  MarketplaceState copyWith({
    List<ProductModel>? products,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MarketplaceState(
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final ProductRepository _repository;

  MarketplaceNotifier(this._repository) : super(const MarketplaceState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getProducts(
      category: state.selectedCategory == 'All Items' ? 'All' : state.selectedCategory,
      query: state.searchQuery,
    );
    state = state.copyWith(products: list, isLoading: false);
  }

  Future<void> searchProducts(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadProducts();
  }

  Future<void> filterCategory(String category) async {
    state = state.copyWith(selectedCategory: category);
    await loadProducts();
  }

  Future<void> addFarmerProduce(ProductModel product) async {
    await _repository.addProduct(product);
    await loadProducts();
  }
}

final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return MarketplaceNotifier(repo);
});

// --- SHOPPING CART NOTIFIER ---
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItemsCount => items.fold(0, (sum, i) => sum + i.quantityKg.toInt());

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get discount => subtotal * 0.15; // 15% direct farm discount

  double get deliveryFee => items.isEmpty ? 0.0 : 40.0;

  double get platformFee => items.isEmpty ? 0.0 : 15.0;

  double get grandTotal => items.isEmpty ? 0.0 : (subtotal - discount + deliveryFee + platformFee);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addToCart(ProductModel product, [double quantity = 1.0]) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);

    if (existingIndex != -1) {
      final updated = List<CartItem>.from(state.items);
      final current = updated[existingIndex];
      updated[existingIndex] = current.copyWith(
        quantityKg: current.quantityKg + quantity,
      );
      state = CartState(items: updated);
    } else {
      state = CartState(items: [...state.items, CartItem(product: product, quantityKg: quantity)]);
    }
  }

  void updateQuantity(String productId, double newQty) {
    if (newQty <= 0) {
      removeFromCart(productId);
      return;
    }

    final updated = state.items.map((i) {
      if (i.product.id == productId) {
        return i.copyWith(quantityKg: newQty);
      }
      return i;
    }).toList();

    state = CartState(items: updated);
  }

  void removeFromCart(String productId) {
    state = CartState(items: state.items.where((i) => i.product.id != productId).toList());
  }

  void clearCart() {
    state = const CartState(items: []);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// --- ORDERS NOTIFIER ---
class OrdersState {
  final List<OrderModel> customerOrders;
  final List<OrderModel> farmerOrders;
  final bool isLoading;

  const OrdersState({
    this.customerOrders = const [],
    this.farmerOrders = const [],
    this.isLoading = false,
  });

  OrdersState copyWith({
    List<OrderModel>? customerOrders,
    List<OrderModel>? farmerOrders,
    bool? isLoading,
  }) {
    return OrdersState(
      customerOrders: customerOrders ?? this.customerOrders,
      farmerOrders: farmerOrders ?? this.farmerOrders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderRepository _orderRepo;

  OrdersNotifier(this._orderRepo) : super(const OrdersState()) {
    refreshAllOrders();
  }

  Future<void> refreshAllOrders() async {
    state = state.copyWith(isLoading: true);
    final custOrders = await _orderRepo.getOrdersForCustomer('cust-priya');
    final farmOrders = await _orderRepo.getOrdersForFarmer('farmer-ramesh');

    state = state.copyWith(
      customerOrders: custOrders,
      farmerOrders: farmOrders,
      isLoading: false,
    );
  }

  Future<OrderModel> placeOrderFromCart({
    required List<CartItem> items,
    required double totalAmount,
    required String paymentId,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
  }) async {
    final randomOtp = (1000 + Random().nextInt(9000)).toString();
    final firstProduct = items.first.product;

    final newOrder = OrderModel(
      id: 'AGRI-${1000 + Random().nextInt(9000)}',
      customerId: 'cust-current',
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      farmerId: firstProduct.farmerId,
      farmerName: firstProduct.farmerName,
      items: items
          .map((i) => OrderItemSummary(
                productId: i.product.id,
                productTitle: i.product.title,
                quantityKg: i.quantityKg,
                pricePerKg: i.product.pricePerKg,
                totalPrice: i.totalPrice,
              ))
          .toList(),
      subtotal: totalAmount,
      discount: totalAmount * 0.15,
      deliveryFee: 40.0,
      totalAmount: totalAmount,
      paymentMethod: 'Razorpay UPI (Verified)',
      paymentId: paymentId,
      status: OrderStatus.pending,
      deliveryOtp: randomOtp,
      createdAt: DateTime.now(),
    );

    await _orderRepo.createOrder(newOrder);
    await refreshAllOrders();
    return newOrder;
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _orderRepo.updateOrderStatus(orderId, status);
    await refreshAllOrders();
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(repo);
});

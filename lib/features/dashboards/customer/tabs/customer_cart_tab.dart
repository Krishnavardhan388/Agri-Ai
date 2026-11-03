import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/state/auth_provider.dart';
import '../../../marketplace/domain/cart_item_model.dart';
import '../../../marketplace/state/marketplace_provider.dart';

class CustomerCartTab extends ConsumerStatefulWidget {
  const CustomerCartTab({super.key});

  @override
  ConsumerState<CustomerCartTab> createState() => _CustomerCartTabState();
}

class _CustomerCartTabState extends ConsumerState<CustomerCartTab> {
  bool _isProcessingPayment = false;

  Future<void> _handleRazorpayCheckout(CartState cart) async {
    if (cart.items.isEmpty) return;

    setState(() => _isProcessingPayment = true);

    final auth = ref.read(authProvider);
    final razorpaySvc = ref.read(razorpayServiceProvider);

    final customerName = auth.user?.name.isNotEmpty == true ? auth.user!.name : 'Priya Sharma';
    final customerPhone = auth.user?.phone.isNotEmpty == true ? auth.user!.phone : '9876512345';
    final address = auth.user?.location.isNotEmpty == true
        ? auth.user!.location
        : 'Flat 402, Green Meadows, Hanamkonda (2.4 km)';

    await razorpaySvc.openPaymentCheckout(
      amountInRupees: cart.grandTotal,
      customerPhone: customerPhone,
      customerName: customerName,
      onSuccess: (paymentId) async {
        final order = await ref.read(ordersProvider.notifier).placeOrderFromCart(
              items: cart.items,
              totalAmount: cart.grandTotal,
              paymentId: paymentId,
              customerName: customerName,
              customerPhone: customerPhone,
              deliveryAddress: address,
            );

        ref.read(cartProvider.notifier).clearCart();
        setState(() => _isProcessingPayment = false);

        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 28),
                  const SizedBox(width: 8),
                  const Text('Payment Successful!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${order.id} has been placed directly with ${order.farmerName}.'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greenSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Secure Handover OTP:', style: TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                        const SizedBox(height: 4),
                        Text(
                          order.deliveryOtp,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Share this OTP with the delivery partner upon harvest arrival.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Track Order'),
                ),
              ],
            ),
          );
        }
      },
      onFailure: (error) {
        setState(() => _isProcessingPayment = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment cancelled: $error')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Harvest Cart (${cart.totalItemsCount} Items)'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: const Text('Clear', style: TextStyle(color: AppColors.alertRed)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 72, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('Your Cart is Empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 6),
                  const Text('Add farm-fresh harvest directly from local farmers', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ...cart.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _CartItemTile(
                        item: item,
                        onAdd: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantityKg + 1.0),
                        onRemove: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantityKg - 1.0),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // Bill Breakdown Card
                  AgriCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 14),
                        _PriceRow(label: 'Total Produce Value', value: '₹${cart.subtotal.toStringAsFixed(1)}'),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Farm Direct Discount (15%)', value: '-₹${cart.discount.toStringAsFixed(1)}', isDiscount: true),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Delivery Fee (Direct Farm Pickup)', value: '₹${cart.deliveryFee.toInt()}'),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Platform & Packaging Fee', value: '₹${cart.platformFee.toInt()}'),
                        const Divider(height: 24),
                        _PriceRow(label: 'Total Amount Payable', value: '₹${cart.grandTotal.toStringAsFixed(1)}', isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Guaranteed Freshness Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greenSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_rounded, color: AppColors.primaryGreen, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '100% money-back guarantee if farm produce is not fresh on arrival.',
                            style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Razorpay Checkout CTA
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: CustomButton(
                      text: 'Pay ₹${cart.grandTotal.toStringAsFixed(1)} via Razorpay',
                      icon: Icons.payment_rounded,
                      isLoading: _isProcessingPayment,
                      onPressed: () => _handleRazorpayCheckout(cart),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;

    return AgriCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(p.farmerName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text('₹${p.pricePerKg.toStringAsFixed(1)}/kg', style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${item.totalPrice.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.remove, size: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantityKg.toInt()} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDiscount
                ? AppColors.primaryGreen
                : isTotal
                    ? AppColors.primaryDark
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

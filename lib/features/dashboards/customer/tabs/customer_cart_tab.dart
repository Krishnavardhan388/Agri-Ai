import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';

class CustomerCartTab extends StatelessWidget {
  const CustomerCartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Harvest Cart (2 Items)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cart Item 1
            _CartItemTile(
              cropName: 'Fresh Organic Tomatoes',
              farmer: 'Ramesh Farm, Warangal',
              quantity: '5 kg',
              price: '₹175',
              pricePerKg: '₹35/kg',
            ),
            const SizedBox(height: 12),

            // Cart Item 2
            _CartItemTile(
              cropName: 'Sona Masoori Raw Rice',
              farmer: 'Krishna Valley Farms',
              quantity: '10 kg Bag',
              price: '₹550',
              pricePerKg: '₹55/kg',
            ),
            const SizedBox(height: 20),

            // Bill Breakdown Card
            AgriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 14),
                  const _PriceRow(label: 'Total Produce Value', value: '₹725'),
                  const SizedBox(height: 8),
                  const _PriceRow(label: 'Farm Direct Discount (15%)', value: '-₹108', isDiscount: true),
                  const SizedBox(height: 8),
                  const _PriceRow(label: 'Delivery Fee (Direct Farm Pickup)', value: '₹40'),
                  const SizedBox(height: 8),
                  const _PriceRow(label: 'Platform & Packaging Fee', value: '₹15'),
                  const Divider(height: 24),
                  const _PriceRow(label: 'Total Amount Payable', value: '₹672', isTotal: true),
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
                text: 'Proceed to Pay ₹672',
                icon: Icons.payment_rounded,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Razorpay Payment Gateway'),
                      content: const Text(
                        'Razorpay online payment (UPI, Cards, NetBanking) and order creation will be fully wired in Phase 5.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Understood'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final String cropName;
  final String farmer;
  final String quantity;
  final String price;
  final String pricePerKg;

  const _CartItemTile({
    required this.cropName,
    required this.farmer,
    required this.quantity,
    required this.price,
    required this.pricePerKg,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(farmer, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text('$quantity • $pricePerKg', style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.remove, size: 14),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add, size: 14),
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

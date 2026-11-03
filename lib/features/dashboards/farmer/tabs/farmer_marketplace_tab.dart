import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../marketplace/domain/product_model.dart';
import '../../../marketplace/presentation/add_product_screen.dart';
import '../../../marketplace/state/marketplace_provider.dart';

class FarmerMarketplaceTab extends ConsumerWidget {
  const FarmerMarketplaceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketState = ref.watch(marketplaceProvider);
    final products = marketState.products;

    final totalStock = products.fold(0.0, (sum, p) => sum + p.availableStockKg);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Farm Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen, size: 26),
            tooltip: 'Add New Crop',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Summary Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.greenSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greenAccent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(label: 'Active Listings', value: '${products.length} Crops'),
                  const _VerticalDivider(),
                  _SummaryStat(label: 'Total Stock', value: '${totalStock.toInt()} kg'),
                  const _VerticalDivider(),
                  const _SummaryStat(label: 'Sales Revenue', value: '₹48,200'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Listed Crops for Sale',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Produce'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...products.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _FarmerProductItem(product: p),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FarmerProductItem extends StatelessWidget {
  final ProductModel product;

  const _FarmerProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.greenSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.grass_rounded, color: AppColors.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${product.category} • ${product.harvestDate}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: product.isOrganic
                      ? AppColors.primaryGreen.withValues(alpha: 0.1)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.isOrganic ? '100% Organic' : 'Standard',
                  style: TextStyle(
                    color: product.isOrganic ? AppColors.primaryGreen : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price per kg', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('₹${product.pricePerKg.toStringAsFixed(1)} / kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Stock', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('${product.availableStockKg.toInt()} kg available', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Editing "${product.title}" stock & price')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.alertRed),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Archived "${product.title}"')),
                      );
                    },
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

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border,
    );
  }
}

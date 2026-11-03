import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class FarmerMarketplaceTab extends StatelessWidget {
  const FarmerMarketplaceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Farm Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen, size: 26),
            onPressed: () {
              _showAddProductDialog(context);
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(label: 'Active Listings', value: '3 Crops'),
                  _VerticalDivider(),
                  _SummaryStat(label: 'Total Stock', value: '3,250 kg'),
                  _VerticalDivider(),
                  _SummaryStat(label: 'Total Revenue', value: '₹48,200'),
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
                  onPressed: () => _showAddProductDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Produce'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _FarmerProductItem(
              title: 'Fresh Organic Tomatoes',
              category: 'Vegetables',
              pricePerKg: '₹35 / kg',
              availableStock: '450 kg available',
              harvestDate: 'Harvested 2 days ago',
              status: 'In Stock',
              statusColor: AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            _FarmerProductItem(
              title: 'Sona Masoori Raw Rice',
              category: 'Grains & Pulses',
              pricePerKg: '₹55 / kg',
              availableStock: '2,000 kg available',
              harvestDate: 'Current Season Harvest',
              status: 'In Stock',
              statusColor: AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            _FarmerProductItem(
              title: 'Premium Raw Cotton (Kapas)',
              category: 'Cash Crops',
              pricePerKg: '₹75 / kg',
              availableStock: '800 kg available',
              harvestDate: 'Harvested 1 week ago',
              status: 'Selling Fast',
              statusColor: AppColors.earthAmber,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Crop to Marketplace'),
        content: const Text(
          'Farmer product listing with photo upload, kg pricing, and stock inventory will be fully functional in Phase 5 with Cloud Firestore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _FarmerProductItem extends StatelessWidget {
  final String title;
  final String category;
  final String pricePerKg;
  final String availableStock;
  final String harvestDate;
  final String status;
  final Color statusColor;

  const _FarmerProductItem({
    required this.title,
    required this.category,
    required this.pricePerKg,
    required this.availableStock,
    required this.harvestDate,
    required this.status,
    required this.statusColor,
  });

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
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
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
                  Text(pricePerKg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Stock', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(availableStock, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.alertRed),
                    onPressed: () {},
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


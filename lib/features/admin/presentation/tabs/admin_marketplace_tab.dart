import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class AdminMarketplaceTab extends StatelessWidget {
  const AdminMarketplaceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Marketplace Produce Moderation & Quality Assurance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monitor farmer listings, ensure fair pricing alignment against Mandi minimum rates, and flag irregularities.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          AgriCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Farmer Listings',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '12 Active Catalog Items',
                      style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProduceItem(
                  crop: 'Organic Red Tomatoes',
                  farmer: 'Ramesh Kumar (Warangal)',
                  price: '₹35 / kg',
                  stock: '150 kg available',
                  status: 'Approved & Live',
                  color: AppColors.primaryGreen,
                ),
                const Divider(height: 24),
                _buildProduceItem(
                  crop: 'Basmati Paddy (Grade A)',
                  farmer: 'Venkat Rao (Karimnagar)',
                  price: '₹48 / kg',
                  stock: '500 kg available',
                  status: 'Approved & Live',
                  color: AppColors.primaryGreen,
                ),
                const Divider(height: 24),
                _buildProduceItem(
                  crop: 'Organic Cotton (Raw Bales)',
                  farmer: 'Anand Reddy (Adilabad)',
                  price: '₹72 / kg',
                  stock: '300 kg available',
                  status: 'Pending APMC Benchmark Check',
                  color: const Color(0xFFFFA000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProduceItem({
    required String crop,
    required String farmer,
    required String price,
    required String stock,
    required String status,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.eco_rounded, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(crop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(farmer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text(stock, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

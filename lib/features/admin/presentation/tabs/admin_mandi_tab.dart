import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class AdminMandiTab extends StatelessWidget {
  const AdminMandiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Regional Mandi Rates & AI Disease Outbreak Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Broadcast daily floor prices across APMC mandis and send early crop disease outbreak advisories.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Disease Outbreak Alert Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Regional Pest Outbreak Detected: Cotton Pink Bollworm',
                        style: TextStyle(
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'AI Crop Doctor detected 42 confirmed cases across Warangal district in the past 48 hours. Broadcast alert active for 680 cotton farmers.',
                        style: TextStyle(
                          color: Color(0xFFBF360C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mandi Benchmark Table
          AgriCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'APMC Floor Price Benchmarks (₹ / Quintal)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildMandiRateItem(crop: 'Cotton (Medium Staple)', rate: '₹7,120 / Qtl', mandi: 'Warangal Mandi', trend: '+₹140 ↗'),
                const Divider(height: 20),
                _buildMandiRateItem(crop: 'Paddy (Basmati Common)', rate: '₹2,380 / Qtl', mandi: 'Karimnagar APMC', trend: '+₹30 ↗'),
                const Divider(height: 20),
                _buildMandiRateItem(crop: 'Red Chilli (Teja Variety)', rate: '₹18,500 / Qtl', mandi: 'Khammam Mandi', trend: '+₹250 ↗'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiRateItem({
    required String crop,
    required String rate,
    required String mandi,
    required String trend,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(crop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            Text(mandi, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        Row(
          children: [
            Text(rate, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                trend,
                style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


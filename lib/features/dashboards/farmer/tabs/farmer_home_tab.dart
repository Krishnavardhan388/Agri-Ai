import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../mandi_prices/domain/mandi_crop_model.dart';
import '../../../mandi_prices/presentation/mandi_market_screen.dart';
import '../../../smart_farming/state/smart_farming_provider.dart';

class FarmerHomeTab extends ConsumerWidget {
  final VoidCallback onNavigateToDoctor;
  final VoidCallback onNavigateToMarket;

  const FarmerHomeTab({
    super.key,
    required this.onNavigateToDoctor,
    required this.onNavigateToMarket,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartState = ref.watch(smartFarmingProvider);
    final weather = smartState.weather;
    final location = smartState.location;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.greenSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AGRI AI Kisan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(
                    '${location.district}, ${location.state} • ${weather.temperature.toInt()}°C Sunny',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'Update GPS Location',
            onPressed: () {
              ref.read(smartFarmingProvider.notifier).refreshLocationAndWeather();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updating weather & Mandi prices for current GPS position')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new alerts today')),
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
            // Quick AI Doctor Banner CTA
            AgriCard(
              color: AppColors.primaryGreen,
              padding: const EdgeInsets.all(18),
              onTap: onNavigateToDoctor,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'AI CROP DOCTOR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Detect Crop Disease in 3 Seconds',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap here to scan leaves with AI camera',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primaryGreen,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Weather & Farming Advisory
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weather & Farming Advisory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  '${weather.temperature.toInt()}°C • Clear',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AgriCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: AppColors.earthAmber, size: 36),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weather.temperature.toStringAsFixed(1)}°C • ${weather.condition}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Humidity: ${weather.humidity}% • Rain: ${weather.rainProbability}%',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: weather.isSprayingRecommended ? AppColors.greenSurface : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          weather.isSprayingRecommended ? 'Ideal for Spraying' : 'High Wind Risk',
                          style: TextStyle(
                            color: weather.isSprayingRecommended ? AppColors.primaryDark : AppColors.alertRed,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          weather.advisoryDescription,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today's Mandi Rates Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Mandi Rates (${location.district})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MandiMarketScreen()),
                    );
                  },
                  child: const Text('View All Mandis', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            ...smartState.mandiCrops.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _MandiHomeTile(item: item),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MandiHomeTile extends StatelessWidget {
  final MandiCropItem item;

  const _MandiHomeTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${item.variety} • ${item.marketName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.formattedModalPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
              Row(
                children: [
                  Icon(
                    item.isPriceUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                    color: item.isPriceUp ? AppColors.primaryGreen : AppColors.alertRed,
                    size: 18,
                  ),
                  Text(
                    '${item.isPriceUp ? '+' : '-'}₹${item.priceChange.toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.isPriceUp ? AppColors.primaryGreen : AppColors.alertRed,
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

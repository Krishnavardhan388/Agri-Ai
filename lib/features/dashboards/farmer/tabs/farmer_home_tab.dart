import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class FarmerHomeTab extends StatelessWidget {
  final VoidCallback onNavigateToDoctor;
  final VoidCallback onNavigateToMarket;

  const FarmerHomeTab({
    super.key,
    required this.onNavigateToDoctor,
    required this.onNavigateToMarket,
  });

  @override
  Widget build(BuildContext context) {
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AGRI AI Kisan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('Warangal, Telangana • 31°C Sunny', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications today')),
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
            const Text(
              'Weather Advisory',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                              const Text(
                                '31°C • Clear Sky',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Humidity: 62% • Rain Probability: 10%',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.greenSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Ideal for Spraying',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Optimal window for fertilizer application before expected weekend showers.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                const Text(
                  'Daily Mandi Rates (Warangal)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: onNavigateToMarket,
                  child: const Text('View All', style: TextStyle(color: AppColors.primaryGreen)),
                ),
              ],
            ),
            _MandiItemTile(
              cropName: 'Cotton (Kapas)',
              variety: 'Medium Staple',
              mandiPrice: '₹7,250 / Quintal',
              trend: '+₹150',
              isUp: true,
            ),
            const SizedBox(height: 8),
            _MandiItemTile(
              cropName: 'Paddy (Dhan)',
              variety: 'BPT 5204 (Sona Masoori)',
              mandiPrice: '₹2,380 / Quintal',
              trend: '+₹40',
              isUp: true,
            ),
            const SizedBox(height: 8),
            _MandiItemTile(
              cropName: 'Red Chilli (Mirchi)',
              variety: 'Teja Variety',
              mandiPrice: '₹18,500 / Quintal',
              trend: '-₹200',
              isUp: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _MandiItemTile extends StatelessWidget {
  final String cropName;
  final String variety;
  final String mandiPrice;
  final String trend;
  final bool isUp;

  const _MandiItemTile({
    required this.cropName,
    required this.variety,
    required this.mandiPrice,
    required this.trend,
    required this.isUp,
  });

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
              Text(cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(variety, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(mandiPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                    color: isUp ? AppColors.primaryGreen : AppColors.alertRed,
                    size: 20,
                  ),
                  Text(
                    trend,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUp ? AppColors.primaryGreen : AppColors.alertRed,
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


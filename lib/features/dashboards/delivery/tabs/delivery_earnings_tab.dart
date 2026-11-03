import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class DeliveryEarningsTab extends StatelessWidget {
  const DeliveryEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Earnings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Payout Balance Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text('Today\'s Payout', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  const Text('₹1,180.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BannerStat(label: 'Trips Completed', value: '11 Trips'),
                      Container(width: 1, height: 26, color: Colors.white24),
                      _BannerStat(label: 'Total Distance', value: '46.2 km'),
                      Container(width: 1, height: 26, color: Colors.white24),
                      _BannerStat(label: 'Tips Earned', value: '₹140'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Weekly History Card
            AgriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This Week\'s Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  const _EarningRow(day: 'Today (Monday)', amount: '₹1,180', trips: '11 Trips'),
                  const Divider(height: 16),
                  const _EarningRow(day: 'Yesterday (Sunday)', amount: '₹1,840', trips: '18 Trips'),
                  const Divider(height: 16),
                  const _EarningRow(day: 'Saturday', amount: '₹1,420', trips: '14 Trips'),
                  const Divider(height: 16),
                  const _EarningRow(day: 'Friday', amount: '₹950', trips: '9 Trips'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;

  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _EarningRow extends StatelessWidget {
  final String day;
  final String amount;
  final String trips;

  const _EarningRow({
    required this.day,
    required this.amount,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(trips, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark)),
      ],
    );
  }
}


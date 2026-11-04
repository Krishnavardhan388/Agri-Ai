import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class AdminDispatchTab extends StatelessWidget {
  const AdminDispatchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Farm-to-Doorstep Dispatch & Logistics Control',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track active trip assignments, live delivery routes, and 4-digit OTP handover completions.',
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
                      'Live Trip Fleet Operations',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '🟢 3 Active In-Transit',
                      style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDispatchRow(
                  tripId: 'TRIP-4019',
                  driver: 'Suresh Patel',
                  farmer: 'Ramesh Farm (Warangal)',
                  customer: 'Priya Sharma (Subedari)',
                  status: 'In Transit',
                  otpStatus: 'OTP Generated (8842)',
                  color: const Color(0xFF1976D2),
                ),
                const Divider(height: 24),
                _buildDispatchRow(
                  tripId: 'TRIP-4018',
                  driver: 'Rajesh Goud',
                  farmer: 'Venkat Farm (Karimnagar)',
                  customer: 'Kiran Reddy (Kakatiya Colony)',
                  status: 'Delivered',
                  otpStatus: 'Handover Verified ✅',
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchRow({
    required String tripId,
    required String driver,
    required String farmer,
    required String customer,
    required String status,
    required String otpStatus,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.local_shipping_rounded, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tripId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Driver: $driver', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: $farmer', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('To: $customer', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
            const SizedBox(height: 4),
            Text(
              otpStatus,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

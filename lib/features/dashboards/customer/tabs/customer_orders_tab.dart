import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class CustomerOrdersTab extends StatelessWidget {
  const CustomerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Harvest Orders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Active Trackable Order
          AgriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order #AGRI-1092', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Arriving Today, 4:00 PM', style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Fresh Organic Tomatoes (5 kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Text('From Ramesh Farm (Warangal)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),

                // Order Tracking Stepper
                _TrackingStep(
                  title: 'Order Confirmed',
                  subtitle: '10:15 AM • Farmer accepted',
                  isCompleted: true,
                  isLast: false,
                ),
                _TrackingStep(
                  title: 'Fresh Harvest Packed',
                  subtitle: '11:30 AM • Ready for pickup',
                  isCompleted: true,
                  isLast: false,
                ),
                _TrackingStep(
                  title: 'Delivery Partner Assigned',
                  subtitle: 'Suresh Patel (Two-wheeler)',
                  isCompleted: true,
                  isLast: false,
                ),
                _TrackingStep(
                  title: 'Out for Doorstep Delivery',
                  subtitle: 'Driver en route with fresh harvest',
                  isCompleted: false,
                  isCurrent: true,
                  isLast: false,
                ),
                _TrackingStep(
                  title: 'Delivery Confirmed via OTP',
                  subtitle: 'Share OTP with driver upon handover',
                  isCompleted: false,
                  isLast: true,
                ),
                const Divider(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Paid: ₹215 (UPI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call_outlined, size: 16),
                      label: const Text('Contact Driver', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primaryGreen
                    : isCurrent
                        ? AppColors.earthAmber
                        : AppColors.border,
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? AppColors.primaryGreen : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isCompleted || isCurrent ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              if (!isLast) const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class FarmerOrdersTab extends StatelessWidget {
  const FarmerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Farm Orders Received'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _FarmerOrderCard(
            orderId: 'AGRI-1092',
            cropName: 'Fresh Organic Tomatoes (25 kg)',
            customerName: 'Priya Sharma (Hyderabad)',
            orderAmount: '₹875',
            status: 'Pending Dispatch',
            statusColor: AppColors.earthAmber,
            date: 'Today, 11:20 AM',
            isActionable: true,
          ),
          const SizedBox(height: 12),
          _FarmerOrderCard(
            orderId: 'AGRI-1088',
            cropName: 'Sona Masoori Rice (50 kg Bag)',
            customerName: 'Anand Rao (Warangal)',
            orderAmount: '₹2,750',
            status: 'Out for Delivery',
            statusColor: AppColors.primaryLight,
            date: 'Yesterday, 03:45 PM',
            isActionable: false,
          ),
          const SizedBox(height: 12),
          _FarmerOrderCard(
            orderId: 'AGRI-1045',
            cropName: 'Fresh Organic Tomatoes (10 kg)',
            customerName: 'Kavita Reddy (Kazipet)',
            orderAmount: '₹350',
            status: 'Delivered • Completed',
            statusColor: AppColors.primaryGreen,
            date: '29 Oct 2026',
            isActionable: false,
          ),
        ],
      ),
    );
  }
}

class _FarmerOrderCard extends StatelessWidget {
  final String orderId;
  final String cropName;
  final String customerName;
  final String orderAmount;
  final String status;
  final Color statusColor;
  final String date;
  final bool isActionable;

  const _FarmerOrderCard({
    required this.orderId,
    required this.cropName,
    required this.customerName,
    required this.orderAmount,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.isActionable,
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
              Text(
                'Order #$orderId',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            cropName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(customerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Status: Paid via UPI', style: TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                  Text(orderAmount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                ],
              ),
              if (isActionable)
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order marked as packed for delivery pickup!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Pack Harvest', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


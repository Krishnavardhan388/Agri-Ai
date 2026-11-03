import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';

class DeliveryTasksTab extends StatelessWidget {
  const DeliveryTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Partner Tasks'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGreen),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.primaryGreen),
                SizedBox(width: 6),
                Text('Online • Ready', style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Active Assignment Card
          AgriCard(
            border: Border.all(color: AppColors.primaryGreen, width: 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('ACTIVE TRIP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const Text('Trip Payout: ₹95', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark)),
                  ],
                ),
                const SizedBox(height: 14),

                // Pickup: Farm
                _LocationRow(
                  icon: Icons.storefront_rounded,
                  iconColor: AppColors.primaryGreen,
                  label: 'PICKUP FROM FARM',
                  name: 'Ramesh Farm (Gate 2)',
                  address: 'Village Nallabelli, Warangal Rural (3.2 km)',
                  phone: '+91 98765 43210',
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: SizedBox(
                    height: 20,
                    child: VerticalDivider(color: AppColors.border, thickness: 2),
                  ),
                ),
                // Drop: Customer
                _LocationRow(
                  icon: Icons.person_pin_circle_rounded,
                  iconColor: AppColors.alertRed,
                  label: 'DELIVER TO CUSTOMER',
                  name: 'Priya Sharma',
                  address: 'Flat 402, Green Meadows, Hanamkonda (6.5 km)',
                  phone: '+91 98765 12345',
                ),
                const Divider(height: 24),

                // Actions: Maps & Handover OTP
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Maps navigation will launch in Phase 6')),
                          );
                        },
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: const Text('GPS Route', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: 'Enter OTP',
                        icon: Icons.verified_rounded,
                        onPressed: () => _showOtpDialog(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Upcoming Task in Queue
          AgriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('UPCOMING', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const Text('Est. Payout: ₹75', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Krishna Valley Farms → Subedari (4.8 km)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Text('Crop: 10 kg Rice Bag • Weight: Moderate', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Customer Delivery OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ask customer for the 4-digit verification code to confirm handover:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delivery confirmed! ₹95 credited to your wallet.')),
              );
            },
            child: const Text('Verify & Complete'),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String name;
  final String address;
  final String phone;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.name,
    required this.address,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconColor, letterSpacing: 0.5)),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

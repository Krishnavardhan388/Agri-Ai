import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../../auth/presentation/role_selection_screen.dart';
import '../../../auth/state/auth_provider.dart';
import '../../../orders_delivery/state/delivery_provider.dart';

class DeliveryProfileTab extends ConsumerWidget {
  const DeliveryProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final notifier = ref.read(deliveryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AgriCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.greenSurface,
                    child: const Icon(Icons.two_wheeler_rounded, size: 32, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.userName.isNotEmpty ? authState.userName : 'Suresh Patel',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          authState.userPhone.isNotEmpty ? authState.userPhone : '+91 98765 88888',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.greenSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active Delivery Partner • Two Wheeler',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _DeliveryOptionTile(
              icon: Icons.two_wheeler_outlined,
              title: 'Vehicle & Driving License',
              subtitle: 'Hero Splendor Plus • TS 03 AB 4521 (Verified)',
              onTap: () => _showVehicleDialog(context),
            ),
            const SizedBox(height: 10),
            _DeliveryOptionTile(
              icon: Icons.account_balance_outlined,
              title: 'Bank Account & Daily Payouts',
              subtitle: 'State Bank of India • **** 4912',
              onTap: () => _showBankDialog(context),
            ),
            const SizedBox(height: 10),
            _DeliveryOptionTile(
              icon: Icons.swap_horiz_rounded,
              title: 'Switch Role Mode',
              subtitle: 'Switch to Farmer or Customer',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _DeliveryOptionTile(
              icon: Icons.headset_mic_outlined,
              title: 'Partner Support Line',
              subtitle: 'Call 1800-425-1660 (24x7 Helpline)',
              onTap: () => notifier.launchPhone('18004251660'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.alertRed),
                label: const Text('Log Out', style: TextStyle(color: AppColors.alertRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.alertRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.two_wheeler_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('Vehicle & License', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Vehicle Model', 'Hero Splendor Plus (100cc)'),
            _buildDetailRow('Plate Number', 'TS 03 AB 4521'),
            _buildDetailRow('Driving License', 'DL-TS-03-2018-009412'),
            _buildDetailRow('RC Status', 'Valid (Exp: Oct 2029)'),
            _buildDetailRow('Insurance', 'National Insurance (Active)'),
            _buildDetailRow('Max Cargo Load', '35 kg rear carrier box'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBankDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('Settlement Bank Account', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Bank Name', 'State Bank of India'),
            _buildDetailRow('Account No.', 'XXXX XXXX 4912'),
            _buildDetailRow('IFSC Code', 'SBIN0020188 (Warangal Branch)'),
            _buildDetailRow('Primary UPI', 'driver.kisan@okhdfcbank'),
            _buildDetailRow('Settlement', 'Daily Auto-Settlement at 9:00 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DeliveryOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DeliveryOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

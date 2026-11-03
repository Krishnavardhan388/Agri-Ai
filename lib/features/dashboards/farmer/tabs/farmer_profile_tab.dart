import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../../auth/presentation/role_selection_screen.dart';
import '../../../auth/state/auth_provider.dart';

class FarmerProfileTab extends ConsumerWidget {
  const FarmerProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kisan Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Header Card
            AgriCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.greenSurface,
                    child: const Icon(Icons.person_rounded, size: 36, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.userName.isNotEmpty ? authState.userName : 'Ramesh Kumar',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authState.userPhone.isNotEmpty ? authState.userPhone : '+91 98765 43210',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.greenSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Verified Farmer • Warangal',
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
            const SizedBox(height: 20),

            // Agricultural Settings Section
            _ProfileOptionTile(
              icon: Icons.language_rounded,
              title: 'Preferred App Language',
              subtitle: 'Telugu (తెలుగు) / English / Hindi',
              onTap: () {
                _showLanguagePicker(context);
              },
            ),
            const SizedBox(height: 10),
            _ProfileOptionTile(
              icon: Icons.mic_rounded,
              title: 'AGRI MITRA Voice Assistant',
              subtitle: 'Voice enabled for diagnosis & mandi questions',
              trailing: const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 20),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ProfileOptionTile(
              icon: Icons.swap_horiz_rounded,
              title: 'Switch User Mode',
              subtitle: 'Switch to Customer or Delivery Partner',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _ProfileOptionTile(
              icon: Icons.security_rounded,
              title: 'Privacy & Permissions',
              subtitle: 'GPS Location & Camera permissions',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ProfileOptionTile(
              icon: Icons.help_outline_rounded,
              title: 'Kisan Helpline & Support',
              subtitle: 'Toll-free 1800-180-1551 (Kisan Call Center)',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // Logout Button
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

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.translate, color: AppColors.primaryGreen),
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: AppColors.primaryGreen),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.translate, color: AppColors.primaryGreen),
              title: const Text('తెలుగు (Telugu)'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.translate, color: AppColors.primaryGreen),
              title: const Text('हिन्दी (Hindi)'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

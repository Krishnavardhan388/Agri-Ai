import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          _buildWelcomeBanner(context),
          const SizedBox(height: 24),

          // Key Metrics Grid
          const Text(
            'Platform Vital Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildKpiGrid(context),
          const SizedBox(height: 28),

          // Platform Activity Summary
          _buildPlatformActivityRow(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B382B), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🌾 REGIONAL APMC & AGRI-TECH COMMAND',
                    style: TextStyle(
                      color: Color(0xFFA5D6A7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to AGRI AI Operations Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Monitor real-time crop disease detections, verify organic farmers, track mandi price shifts, and oversee doorstep dispatch operations.',
                  style: TextStyle(
                    color: Color(0xFFE8F5E9),
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width >= 800) ...[
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width >= 1100 ? 4 : (width >= 650 ? 2 : 1);

    final kpis = [
      const _KpiCardData(
        title: 'Total Platform GMV',
        value: '₹1,48,250',
        subtitle: '+18.4% this week',
        icon: Icons.currency_rupee_rounded,
        iconColor: Color(0xFF2E7D32),
        bgColor: Color(0xFFE8F5E9),
      ),
      const _KpiCardData(
        title: 'Verified Farmers',
        value: '1,248',
        subtitle: '14 awaiting approval',
        icon: Icons.agriculture_rounded,
        iconColor: Color(0xFF1565C0),
        bgColor: Color(0xFFE3F2FD),
      ),
      const _KpiCardData(
        title: 'AI Crop Scans Done',
        value: '5,820',
        subtitle: '89.4% healthy diagnoses',
        icon: Icons.biotech_rounded,
        iconColor: Color(0xFF7B1FA2),
        bgColor: Color(0xFFF3E5F5),
      ),
      const _KpiCardData(
        title: 'Active Delivery Fleet',
        value: '164',
        subtitle: '42 trips in-transit',
        icon: Icons.two_wheeler_rounded,
        iconColor: Color(0xFFE65100),
        bgColor: Color(0xFFFFF3E0),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 154,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return AgriCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      kpi.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kpi.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(kpi.icon, color: kpi.iconColor, size: 20),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kpi.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kpi.subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: kpi.subtitle.contains('+')
                          ? const Color(0xFF2E7D32)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlatformActivityRow(BuildContext context) {
    return AgriCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Operations Feed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Real-time Firestore Sync',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.biotech_rounded,
            iconColor: Colors.purple,
            title: 'Cotton Pink Bollworm Detected',
            subtitle: 'Warangal District • Confidence 94% • High severity advisory generated',
            time: '2 mins ago',
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.primaryGreen,
            title: 'Farm Order #AGRI-8821 Completed',
            subtitle: 'OTP 8842 verified by Suresh Patel (Delivery Partner) • ₹1,250 paid via Razorpay',
            time: '14 mins ago',
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.verified_user_rounded,
            iconColor: Colors.blue,
            title: 'New Organic Certification Submitted',
            subtitle: 'Kisan Ramesh Kumar submitted Telangana State Organic Certification for paddy harvest',
            time: '42 mins ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          time,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _KpiCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _KpiCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

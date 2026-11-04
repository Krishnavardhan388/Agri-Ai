import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/admin_section.dart';

class AdminTopBar extends StatelessWidget {
  final AdminSection currentSection;
  final bool isDesktop;
  final VoidCallback onOpenDrawer;
  final VoidCallback onRefresh;
  final VoidCallback onSwitchToMobileApp;

  const AdminTopBar({
    super.key,
    required this.currentSection,
    required this.isDesktop,
    required this.onOpenDrawer,
    required this.onRefresh,
    required this.onSwitchToMobileApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: onOpenDrawer,
              tooltip: 'Open Navigation Menu',
            ),
            const SizedBox(width: 8),
          ],

          // Title & Breadcrumb
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AGRI AI Admin / ${currentSection.title}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  currentSection.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Live Status Badge
          if (MediaQuery.of(context).size.width >= 720) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Operational 100%',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Quick Refresh
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh Platform Metrics',
            onPressed: onRefresh,
          ),
          const SizedBox(width: 4),

          // Switch To Mobile App Role
          OutlinedButton.icon(
            onPressed: onSwitchToMobileApp,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.phone_android_rounded, size: 18),
            label: Text(
              MediaQuery.of(context).size.width >= 600 ? 'Switch Role' : 'Role',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

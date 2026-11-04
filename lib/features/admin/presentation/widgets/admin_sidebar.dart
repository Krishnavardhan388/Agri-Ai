import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/admin_section.dart';

class AdminSidebar extends StatelessWidget {
  final AdminSection selectedSection;
  final bool isCollapsed;
  final ValueChanged<AdminSection> onSelectSection;
  final VoidCallback onToggleCollapse;

  const AdminSidebar({
    super.key,
    required this.selectedSection,
    required this.isCollapsed,
    required this.onSelectSection,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final width = isCollapsed ? 80.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF1B382B), // Deep Forest Evergreen
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding Header
          _buildHeader(),
          const Divider(color: Colors.white12, height: 1),

          // Navigation Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: AdminSection.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final section = AdminSection.values[index];
                final isSelected = section == selectedSection;

                return _buildNavItem(section, isSelected);
              },
            ),
          ),

          const Divider(color: Colors.white12, height: 1),
          // Footer with Admin User Profile & Collapse Toggle
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 78,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 16 : 20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AGRI AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPS CONTROL',
                      style: TextStyle(
                        color: Color(0xFFC8E6C9),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(AdminSection section, bool isSelected) {
    final item = InkWell(
      onTap: () => onSelectSection(section),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: isCollapsed ? 14 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF81C784).withValues(alpha: 0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              section.icon,
              color: isSelected ? Colors.white : const Color(0xFFA5D6A7),
              size: 22,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFECEFF1),
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (section.badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: section.badgeText == 'LIVE'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFFA000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    section.badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: section.title,
        waitDuration: const Duration(milliseconds: 300),
        child: item,
      );
    }

    return item;
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 12 : 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: isCollapsed ? 16 : 18,
            backgroundColor: AppColors.primaryGreen,
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin Officer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'HQ Operations',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white70,
                size: 20,
              ),
              tooltip: 'Collapse Sidebar',
              onPressed: onToggleCollapse,
            ),
          ] else
            Expanded(
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                tooltip: 'Expand Sidebar',
                onPressed: onToggleCollapse,
              ),
            ),
        ],
      ),
    );
  }
}

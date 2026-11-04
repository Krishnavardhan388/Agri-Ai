import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/role_selection_screen.dart';
import '../domain/admin_section.dart';
import '../state/admin_provider.dart';
import 'tabs/admin_dispatch_tab.dart';
import 'tabs/admin_mandi_tab.dart';
import 'tabs/admin_marketplace_tab.dart';
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_settings_tab.dart';
import 'tabs/admin_verification_tab.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_top_bar.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onSelectSection(AdminSection section) {
    ref.read(adminProvider.notifier).selectSection(section);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _handleSwitchRole() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('Switch Experience', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Would you like to return to the mobile role selection screen to view Farmer, Buyer, or Delivery Partner experiences?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay in Admin'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go to Role Selector'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminSection section) {
    switch (section) {
      case AdminSection.overview:
        return const AdminOverviewTab();
      case AdminSection.userVerification:
        return const AdminVerificationTab();
      case AdminSection.marketplaceModeration:
        return const AdminMarketplaceTab();
      case AdminSection.liveDispatch:
        return const AdminDispatchTab();
      case AdminSection.mandiOutbreaks:
        return const AdminMandiTab();
      case AdminSection.systemSettings:
        return const AdminSettingsTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F5),
      drawer: !isDesktop
          ? Drawer(
              child: AdminSidebar(
                selectedSection: adminState.currentSection,
                isCollapsed: false,
                onSelectSection: _onSelectSection,
                onToggleCollapse: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              selectedSection: adminState.currentSection,
              isCollapsed: adminState.isSidebarCollapsed,
              onSelectSection: _onSelectSection,
              onToggleCollapse: () => ref.read(adminProvider.notifier).toggleSidebar(),
            ),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(
                  currentSection: adminState.currentSection,
                  isDesktop: isDesktop,
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                  onRefresh: () {
                    ref.read(adminProvider.notifier).refreshData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Platform metrics updated in real-time'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onSwitchToMobileApp: _handleSwitchRole,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _buildBody(adminState.currentSection),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

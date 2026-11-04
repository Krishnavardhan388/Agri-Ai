import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/admin/domain/admin_section.dart';
import 'package:agri_ai/features/admin/presentation/admin_main_screen.dart';
import 'package:agri_ai/features/admin/state/admin_provider.dart';
import 'package:agri_ai/features/auth/domain/user_role.dart';

void main() {
  group('Admin Domain & Role Tests', () {
    test('UserRole.admin has valid attributes', () {
      const role = UserRole.admin;
      expect(role.displayName, 'Operations Administrator');
      expect(role.shortName, 'Admin');
      expect(role.description, contains('Platform control center'));
      expect(role.icon, Icons.admin_panel_settings_rounded);
    });

    test('AdminSection has distinct titles and icons', () {
      for (final section in AdminSection.values) {
        expect(section.title.isNotEmpty, true);
        expect(section.icon, isNotNull);
      }
      expect(AdminSection.userVerification.badgeText, '4 New');
      expect(AdminSection.liveDispatch.badgeText, 'LIVE');
      expect(AdminSection.overview.badgeText, isNull);
    });
  });

  group('Admin State Provider Tests', () {
    test('AdminNotifier initial state and tab selection', () {
      final notifier = AdminNotifier();
      expect(notifier.state.currentSection, AdminSection.overview);
      expect(notifier.state.isSidebarCollapsed, false);
      expect(notifier.state.isLiveSyncActive, true);

      notifier.selectSection(AdminSection.marketplaceModeration);
      expect(notifier.state.currentSection, AdminSection.marketplaceModeration);

      notifier.toggleSidebar();
      expect(notifier.state.isSidebarCollapsed, true);

      notifier.setSidebarCollapsed(false);
      expect(notifier.state.isSidebarCollapsed, false);
    });
  });

  group('Admin UI Widget Tests', () {
    testWidgets('AdminMainScreen renders top bar and overview content', (tester) async {
      // Set desktop screen resolution
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminMainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top bar title & branding
      expect(find.textContaining('AGRI AI Admin'), findsOneWidget);
      expect(find.text('Overview & Analytics'), findsWidgets);
      expect(find.text('Platform Vital Statistics'), findsOneWidget);

      // Check KPI Cards
      expect(find.text('Total Platform GMV'), findsOneWidget);
      expect(find.text('Verified Farmers'), findsOneWidget);
      expect(find.text('AI Crop Scans Done'), findsOneWidget);
      expect(find.text('Active Delivery Fleet'), findsOneWidget);
    });

    testWidgets('Switching section updates active view', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AdminMainScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Verification section
      container.read(adminProvider.notifier).selectSection(AdminSection.userVerification);
      await tester.pumpAndSettle();

      expect(find.text('Farmer & Delivery Partner Verification Queue'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);

      // Switch to Mandi & Outbreaks
      container.read(adminProvider.notifier).selectSection(AdminSection.mandiOutbreaks);
      await tester.pumpAndSettle();

      expect(find.textContaining('Cotton Pink Bollworm'), findsOneWidget);
    });
  });
}

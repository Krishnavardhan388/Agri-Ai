import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/admin/data/admin_analytics_repository.dart';
import 'package:agri_ai/features/admin/domain/admin_analytics_summary.dart';
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

    test('AdminTimeframe provides proper human-readable labels', () {
      expect(AdminTimeframe.thisWeek.label, 'Last 7 Days');
      expect(AdminTimeframe.thisMonth.label, 'This Month');
      expect(AdminTimeframe.allTime.label, 'All Time');
    });
  });

  group('Admin Analytics Repository Tests', () {
    late AdminAnalyticsRepository repo;

    setUp(() {
      repo = AdminAnalyticsRepository();
    });

    test('Repository calculates metrics across timeframes', () async {
      final weekSummary = await repo.getAnalyticsSummary(timeframe: AdminTimeframe.thisWeek);
      expect(weekSummary.totalGmv, 148250.0);
      expect(weekSummary.topDiseases.isNotEmpty, true);
      expect(weekSummary.weeklyRevenue.length, 7);

      final monthSummary = await repo.getAnalyticsSummary(timeframe: AdminTimeframe.thisMonth);
      expect(monthSummary.totalGmv, greaterThan(weekSummary.totalGmv));
      expect(monthSummary.totalOrders, greaterThan(weekSummary.totalOrders));
    });

    test('Repository records district broadcast alerts', () async {
      final success = await repo.sendDistrictBroadcastAlert(
        district: 'Warangal District',
        crop: 'Cotton',
        advisory: 'Spray Neem oil',
      );
      expect(success, true);
      expect(repo.broadcastAlerts.length, 1);
      expect(repo.broadcastAlerts.first['district'], 'Warangal District');
    });

    test('Repository generates formatted text export audit report', () async {
      final summary = AdminAnalyticsSummary.mockInitial();
      final report = repo.generateExportReport(summary);

      expect(report, contains('AGRI AI — OPERATIONS EXECUTIVE AUDIT SUMMARY'));
      expect(report, contains('₹148250.00'));
      expect(report, contains('Cotton (Pink Bollworm'));
    });
  });

  group('Admin State Provider Tests', () {
    test('AdminNotifier initial state, tab selection, and timeframe shift', () async {
      final notifier = AdminNotifier();
      expect(notifier.state.currentSection, AdminSection.overview);
      expect(notifier.state.isSidebarCollapsed, false);
      expect(notifier.state.timeframe, AdminTimeframe.thisWeek);
      expect(notifier.state.analytics.totalGmv, 148250.0);

      notifier.selectSection(AdminSection.marketplaceModeration);
      expect(notifier.state.currentSection, AdminSection.marketplaceModeration);

      notifier.toggleSidebar();
      expect(notifier.state.isSidebarCollapsed, true);

      await notifier.setTimeframe(AdminTimeframe.thisMonth);
      expect(notifier.state.timeframe, AdminTimeframe.thisMonth);
      expect(notifier.state.analytics.totalGmv, greaterThan(148250.0));
    });

    test('AdminNotifier broadcast alert updates state confirmation', () async {
      final notifier = AdminNotifier();
      final success = await notifier.broadcastOutbreakAlert(
        district: 'Warangal District',
        crop: 'Cotton',
        advisory: 'Advisory test',
      );
      expect(success, true);
      expect(notifier.state.lastAlertSentMessage, contains('Warangal District'));
    });
  });

  group('Admin UI Widget Tests', () {
    testWidgets('AdminMainScreen renders top bar, KPIs, and charts', (tester) async {
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
      expect(find.text('Executive Key Performance Indicators'), findsOneWidget);

      // Check KPI Cards
      expect(find.text('Total Platform GMV'), findsOneWidget);
      expect(find.text('Verified Farmers'), findsOneWidget);
      expect(find.text('AI Crop Scans Done'), findsOneWidget);
      expect(find.text('Active Delivery Fleet'), findsOneWidget);

      // Check Charts and Quick Action Buttons
      expect(find.text('Revenue & Order Volume Trend'), findsOneWidget);
      expect(find.text('AI Crop Doctor Pathology Distribution'), findsOneWidget);
      expect(find.text('Broadcast Outbreak Alert'), findsOneWidget);
      expect(find.text('Export Executive Report'), findsOneWidget);
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

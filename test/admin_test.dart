import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/admin/data/admin_analytics_repository.dart';
import 'package:agri_ai/features/admin/data/admin_dispatch_repository.dart';
import 'package:agri_ai/features/admin/data/admin_kyc_repository.dart';
import 'package:agri_ai/features/admin/data/admin_mandi_controller_repository.dart';
import 'package:agri_ai/features/admin/data/admin_marketplace_repository.dart';
import 'package:agri_ai/features/admin/domain/admin_analytics_summary.dart';
import 'package:agri_ai/features/admin/domain/admin_dispatch_trip.dart';
import 'package:agri_ai/features/admin/domain/admin_marketplace_item.dart';
import 'package:agri_ai/features/admin/domain/admin_section.dart';
import 'package:agri_ai/features/admin/domain/kyc_application_model.dart';
import 'package:agri_ai/features/admin/presentation/admin_main_screen.dart';
import 'package:agri_ai/features/admin/state/admin_provider.dart';
import 'package:agri_ai/features/admin/state/dispatch_provider.dart';
import 'package:agri_ai/features/admin/state/kyc_provider.dart';
import 'package:agri_ai/features/admin/state/mandi_controller_provider.dart';
import 'package:agri_ai/features/admin/state/marketplace_moderation_provider.dart';
import 'package:agri_ai/features/admin/state/system_settings_provider.dart';
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

    test('KycStatus has valid color and titles', () {
      expect(KycStatus.pending.displayName, 'Pending Review');
      expect(KycStatus.approved.displayName, 'Verified & Active');
      expect(KycStatus.rejected.displayName, 'Rejected');
    });

    test('ProductModerationStatus has valid color and icons', () {
      expect(ProductModerationStatus.active.displayName, 'Active & Approved');
      expect(ProductModerationStatus.priceAlert.displayName, 'Price Anomaly Alert');
      expect(ProductModerationStatus.unlisted.displayName, 'Unlisted / Paused');
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

  group('Admin KYC Repository Tests', () {
    late AdminKycRepository kycRepo;

    setUp(() {
      kycRepo = AdminKycRepository();
    });

    test('Repository returns seeded applications and counts', () async {
      final list = await kycRepo.getApplications();
      expect(list.length, greaterThanOrEqualTo(6));
      expect(kycRepo.getPendingCount(), 3);
    });

    test('Repository filters by status and role', () async {
      final pendingOnly = await kycRepo.getApplications(status: KycStatus.pending);
      for (final app in pendingOnly) {
        expect(app.status, KycStatus.pending);
      }

      final farmersOnly = await kycRepo.getApplications(role: UserRole.farmer);
      for (final app in farmersOnly) {
        expect(app.role, UserRole.farmer);
      }

      final driversOnly = await kycRepo.getApplications(role: UserRole.deliveryPartner);
      for (final app in driversOnly) {
        expect(app.role, UserRole.deliveryPartner);
      }
    });

    test('Repository searches by applicant name and document number', () async {
      final searchRamesh = await kycRepo.getApplications(searchQuery: 'Ramesh');
      expect(searchRamesh.any((a) => a.applicantName.contains('Ramesh')), true);

      final searchDoc = await kycRepo.getApplications(searchQuery: 'TS-03-EB-4421');
      expect(searchDoc.length, 1);
      expect(searchDoc.first.applicantName, 'Suresh Patel');
    });

    test('Repository approves and rejects application correctly', () async {
      final approveSuccess = await kycRepo.approveApplication('KYC-FARM-101');
      expect(approveSuccess, true);

      final updatedPending = await kycRepo.getApplications(status: KycStatus.pending);
      expect(updatedPending.any((a) => a.id == 'KYC-FARM-101'), false);

      final rejectSuccess = await kycRepo.rejectApplication(
        'KYC-DRV-202',
        reason: 'Illegible vehicle RC photo',
      );
      expect(rejectSuccess, true);

      final rejectedApps = await kycRepo.getApplications(status: KycStatus.rejected);
      final rejected = rejectedApps.firstWhere((a) => a.id == 'KYC-DRV-202');
      expect(rejected.status, KycStatus.rejected);
      expect(rejected.rejectionReason, contains('Illegible vehicle RC photo'));
    });
  });

  group('Admin Marketplace & Moderation Tests', () {
    late AdminMarketplaceRepository marketRepo;

    setUp(() {
      marketRepo = AdminMarketplaceRepository();
    });

    test('Repository returns seeded produce with price anomalies', () async {
      final products = await marketRepo.getProducts();
      expect(products.length, 6);
      expect(marketRepo.getPriceAnomalyCount(), 1);

      final onion = products.firstWhere((p) => p.id == 'prod-onion-4');
      expect(onion.hasHighDeviation, true);
      expect(onion.priceDeviationPercent, greaterThan(50.0));
    });

    test('Repository updates stock, status, and organic tag', () async {
      final updateSuccess = await marketRepo.updateProductStatus('prod-onion-4', ProductModerationStatus.active);
      expect(updateSuccess, true);

      final stockSuccess = await marketRepo.updateStock('prod-tomato-1', 200.0);
      expect(stockSuccess, true);

      final organicSuccess = await marketRepo.toggleOrganicStatus('prod-cotton-5');
      expect(organicSuccess, true);
    });

    test('MarketplaceModerationNotifier manages filters and actions', () async {
      final notifier = MarketplaceModerationNotifier();
      await notifier.loadProducts();
      expect(notifier.state.products.length, 6);

      await notifier.toggleOrganicFilter();
      expect(notifier.state.onlyOrganic, true);

      await notifier.flagPriceWarning('prod-onion-4', 'Price is too high');
      expect(notifier.state.actionMessage, contains('Price anomaly alert'));
    });
  });

  group('Admin Mandi Controller Tests', () {
    late AdminMandiControllerRepository mandiRepo;

    setUp(() {
      mandiRepo = AdminMandiControllerRepository();
    });

    test('Repository fetches APMC rates and updates benchmarks', () async {
      final rates = await mandiRepo.getRates();
      expect(rates.length, 5);

      final cotton = rates.firstWhere((r) => r.id == 'mandi-cotton-1');
      expect(cotton.modalPricePerQuintal, 7120.0);

      final updateSuccess = await mandiRepo.updateRate('mandi-cotton-1', 7300.0);
      expect(updateSuccess, true);

      final updatedRates = await mandiRepo.getRates();
      final updatedCotton = updatedRates.firstWhere((r) => r.id == 'mandi-cotton-1');
      expect(updatedCotton.modalPricePerQuintal, 7300.0);
      expect(updatedCotton.isRising, true);
    });

    test('MandiControllerNotifier handles rates and broadcasting', () async {
      final notifier = MandiControllerNotifier();
      await notifier.loadRates();
      expect(notifier.state.rates.length, 5);

      await notifier.broadcastRate('mandi-cotton-1');
      expect(notifier.state.actionMessage, contains('Broadcast sent to farmers'));
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

    test('KycNotifier loads applications and filters dynamically', () async {
      final kycNotifier = KycNotifier();
      await kycNotifier.loadApplications();
      expect(kycNotifier.state.applications.isNotEmpty, true);

      await kycNotifier.setStatusFilter(KycStatus.pending);
      expect(kycNotifier.state.selectedStatus, KycStatus.pending);
      expect(kycNotifier.state.applications.every((a) => a.status == KycStatus.pending), true);

      await kycNotifier.approve('KYC-FARM-101');
      expect(kycNotifier.state.actionMessage, contains('KYC-FARM-101 approved'));
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

    testWidgets('Switching section updates active view and renders KYC, Marketplace, and Mandi tabs', (tester) async {
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

      // 1. Switch to Verification section
      container.read(adminProvider.notifier).selectSection(AdminSection.userVerification);
      await tester.pumpAndSettle();

      expect(find.text('Farmer & Delivery Partner Verification Queue'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('Suresh Patel'), findsOneWidget);

      // 2. Switch to Marketplace section
      container.read(adminProvider.notifier).selectSection(AdminSection.marketplaceModeration);
      await tester.pumpAndSettle();

      expect(find.text('Marketplace Produce Moderation & Quality Assurance'), findsOneWidget);
      expect(find.textContaining('Fresh Organic Red Tomatoes'), findsOneWidget);
      expect(find.textContaining('Fresh Red Onions'), findsOneWidget);

      // 3. Switch to Mandi & Outbreaks
      container.read(adminProvider.notifier).selectSection(AdminSection.mandiOutbreaks);
      await tester.pumpAndSettle();

      expect(find.textContaining('Cotton Pink Bollworm'), findsOneWidget);
      expect(find.textContaining('Cotton (Medium Staple)'), findsOneWidget);
      expect(find.textContaining('Warangal APMC Mandi'), findsOneWidget);

      // 4. Switch to Live Dispatch
      container.read(adminProvider.notifier).selectSection(AdminSection.liveDispatch);
      await tester.pumpAndSettle();

      expect(find.text('Live Farm-to-Doorstep Dispatch & Logistics Control'), findsOneWidget);
      expect(find.textContaining('TRIP-4019'), findsOneWidget);
      expect(find.textContaining('Suresh Patel'), findsWidgets);

      // 5. Switch to System Settings
      container.read(adminProvider.notifier).selectSection(AdminSection.systemSettings);
      await tester.pumpAndSettle();

      expect(find.text('System Configurations & Platform Control Center'), findsOneWidget);
      expect(find.text('Google Gemini Vision AI Engine'), findsOneWidget);
      expect(find.text('Razorpay Payment Gateway'), findsOneWidget);
      expect(find.text('Marketplace Economics & Platform Commission'), findsOneWidget);
      expect(find.text('AGRI MITRA Regional Voice Assistant Tuning'), findsOneWidget);
    });
  });

  group('Admin Dispatch Repository & Provider Tests', () {
    late AdminDispatchRepository dispatchRepo;

    setUp(() {
      dispatchRepo = AdminDispatchRepository();
    });

    test('Loads seeded active trips and returns proper counts', () async {
      final trips = await dispatchRepo.getTrips();
      expect(trips.length, greaterThanOrEqualTo(4));

      final activeCount = dispatchRepo.getActiveCount();
      expect(activeCount, greaterThanOrEqualTo(1));
    });

    test('Filters trips by status and search query', () async {
      final inTransitOnly = await dispatchRepo.getTrips(status: DispatchStatus.inTransit);
      expect(inTransitOnly.isNotEmpty, true);
      for (final trip in inTransitOnly) {
        expect(trip.status, DispatchStatus.inTransit);
      }

      final searchResults = await dispatchRepo.getTrips(searchQuery: 'Suresh');
      expect(searchResults.length, 1);
      expect(searchResults.first.tripId, 'TRIP-4019');
    });

    test('Reassigns driver successfully', () async {
      final success = await dispatchRepo.reassignDriver(
        'TRIP-4019',
        newDriverName: 'Rajesh Goud',
        newDriverPhone: '+91 98765 44332',
        newDriverVehicle: 'Piaggio Ape Cargo (TS-03-TR-9102)',
      );
      expect(success, true);

      final trip = (await dispatchRepo.getTrips()).firstWhere((t) => t.tripId == 'TRIP-4019');
      expect(trip.driverName, 'Rajesh Goud');
      expect(trip.driverPhone, '+91 98765 44332');
      expect(trip.driverVehicle, 'Piaggio Ape Cargo (TS-03-TR-9102)');
    });

    test('Admin overrides OTP and delivers package', () async {
      final success = await dispatchRepo.overrideVerifyOtp('TRIP-4019');
      expect(success, true);

      final trip = (await dispatchRepo.getTrips()).firstWhere((t) => t.tripId == 'TRIP-4019');
      expect(trip.status, DispatchStatus.delivered);
      expect(trip.isOtpOverridden, true);
    });

    test('DispatchProvider notifier loads and updates trips', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(dispatchProvider.notifier).loadTrips();
      final trips = container.read(dispatchProvider).trips;
      expect(trips.isNotEmpty, true);

      await container.read(dispatchProvider.notifier).setStatusFilter(DispatchStatus.inTransit);
      expect(container.read(dispatchProvider).selectedStatus, DispatchStatus.inTransit);
    });
  });

  group('System Settings Provider Tests', () {
    test('SystemSettingsNotifier modifies parameters cleanly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(systemSettingsProvider).settings;
      expect(initial.geminiModel, contains('Flash'));
      expect(initial.platformCommissionPercent, 5.0);
      expect(initial.defaultVoiceSpeechRate, 0.48);
      expect(initial.isAutoDispatchEnabled, true);

      final notifier = container.read(systemSettingsProvider.notifier);

      notifier.updateGeminiModel('Gemini 1.5 Pro (Multimodal)');
      expect(container.read(systemSettingsProvider).settings.geminiModel, 'Gemini 1.5 Pro (Multimodal)');

      notifier.setRazorpayMode('Production Live Mode');
      expect(container.read(systemSettingsProvider).settings.razorpayMode, 'Production Live Mode');

      notifier.updateCommission(7.5);
      expect(container.read(systemSettingsProvider).settings.platformCommissionPercent, 7.5);

      notifier.updateSpeechRate(0.55);
      expect(container.read(systemSettingsProvider).settings.defaultVoiceSpeechRate, 0.55);

      notifier.toggleAutoDispatch();
      expect(container.read(systemSettingsProvider).settings.isAutoDispatchEnabled, false);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/admin_analytics_repository.dart';
import '../domain/admin_analytics_summary.dart';
import '../domain/admin_section.dart';

class AdminState {
  final AdminSection currentSection;
  final bool isSidebarCollapsed;
  final bool isLiveSyncActive;
  final DateTime lastRefreshed;
  final AdminTimeframe timeframe;
  final AdminAnalyticsSummary analytics;
  final bool isLoadingAnalytics;
  final String? lastAlertSentMessage;

  const AdminState({
    this.currentSection = AdminSection.overview,
    this.isSidebarCollapsed = false,
    this.isLiveSyncActive = true,
    required this.lastRefreshed,
    this.timeframe = AdminTimeframe.thisWeek,
    required this.analytics,
    this.isLoadingAnalytics = false,
    this.lastAlertSentMessage,
  });

  AdminState copyWith({
    AdminSection? currentSection,
    bool? isSidebarCollapsed,
    bool? isLiveSyncActive,
    DateTime? lastRefreshed,
    AdminTimeframe? timeframe,
    AdminAnalyticsSummary? analytics,
    bool? isLoadingAnalytics,
    String? lastAlertSentMessage,
  }) {
    return AdminState(
      currentSection: currentSection ?? this.currentSection,
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      isLiveSyncActive: isLiveSyncActive ?? this.isLiveSyncActive,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
      timeframe: timeframe ?? this.timeframe,
      analytics: analytics ?? this.analytics,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      lastAlertSentMessage: lastAlertSentMessage ?? this.lastAlertSentMessage,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminAnalyticsRepository repository;

  AdminNotifier({AdminAnalyticsRepository? repository})
      : repository = repository ?? AdminAnalyticsRepository(),
        super(
          AdminState(
            lastRefreshed: DateTime.now(),
            analytics: AdminAnalyticsSummary.mockInitial(),
          ),
        );

  void selectSection(AdminSection section) {
    state = state.copyWith(
      currentSection: section,
      lastRefreshed: DateTime.now(),
    );
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarCollapsed: !state.isSidebarCollapsed);
  }

  void setSidebarCollapsed(bool collapsed) {
    state = state.copyWith(isSidebarCollapsed: collapsed);
  }

  Future<void> setTimeframe(AdminTimeframe timeframe) async {
    state = state.copyWith(timeframe: timeframe, isLoadingAnalytics: true);
    final summary = await repository.getAnalyticsSummary(timeframe: timeframe);
    state = state.copyWith(
      analytics: summary,
      isLoadingAnalytics: false,
      lastRefreshed: DateTime.now(),
    );
  }

  Future<void> refreshData() async {
    state = state.copyWith(isLoadingAnalytics: true);
    final summary = await repository.getAnalyticsSummary(timeframe: state.timeframe);
    state = state.copyWith(
      analytics: summary,
      isLoadingAnalytics: false,
      lastRefreshed: DateTime.now(),
    );
  }

  Future<bool> broadcastOutbreakAlert({
    required String district,
    required String crop,
    required String advisory,
  }) async {
    final success = await repository.sendDistrictBroadcastAlert(
      district: district,
      crop: crop,
      advisory: advisory,
    );
    if (success) {
      state = state.copyWith(
        lastAlertSentMessage: 'Alert successfully broadcast to 680 farmers in $district',
        lastRefreshed: DateTime.now(),
      );
    }
    return success;
  }

  String getExportAuditSummary() {
    return repository.generateExportReport(state.analytics);
  }
}

final adminAnalyticsRepoProvider = Provider<AdminAnalyticsRepository>((ref) {
  return AdminAnalyticsRepository(apiClient: ref.watch(apiClientProvider));
});

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repo = ref.watch(adminAnalyticsRepoProvider);
  return AdminNotifier(repository: repo);
});

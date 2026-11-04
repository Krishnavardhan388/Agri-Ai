import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/admin_section.dart';

class AdminState {
  final AdminSection currentSection;
  final bool isSidebarCollapsed;
  final bool isLiveSyncActive;
  final DateTime lastRefreshed;

  const AdminState({
    this.currentSection = AdminSection.overview,
    this.isSidebarCollapsed = false,
    this.isLiveSyncActive = true,
    required this.lastRefreshed,
  });

  AdminState copyWith({
    AdminSection? currentSection,
    bool? isSidebarCollapsed,
    bool? isLiveSyncActive,
    DateTime? lastRefreshed,
  }) {
    return AdminState(
      currentSection: currentSection ?? this.currentSection,
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      isLiveSyncActive: isLiveSyncActive ?? this.isLiveSyncActive,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier()
      : super(
          AdminState(
            lastRefreshed: DateTime.now(),
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

  void refreshData() {
    state = state.copyWith(lastRefreshed: DateTime.now());
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});

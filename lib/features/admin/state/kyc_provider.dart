import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_role.dart';
import '../data/admin_kyc_repository.dart';
import '../domain/kyc_application_model.dart';

class KycState {
  final List<KycApplication> applications;
  final bool isLoading;
  final KycStatus? selectedStatus;
  final UserRole? selectedRole;
  final String searchQuery;
  final String? actionMessage;

  const KycState({
    required this.applications,
    this.isLoading = false,
    this.selectedStatus,
    this.selectedRole,
    this.searchQuery = '',
    this.actionMessage,
  });

  KycState copyWith({
    List<KycApplication>? applications,
    bool? isLoading,
    KycStatus? selectedStatus,
    bool clearStatus = false,
    UserRole? selectedRole,
    bool clearRole = false,
    String? searchQuery,
    String? actionMessage,
  }) {
    return KycState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedRole: clearRole ? null : (selectedRole ?? this.selectedRole),
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  int get pendingCount => applications.where((a) => a.status == KycStatus.pending).length;
  int get approvedCount => applications.where((a) => a.status == KycStatus.approved).length;
  int get rejectedCount => applications.where((a) => a.status == KycStatus.rejected).length;
}

class KycNotifier extends StateNotifier<KycState> {
  final AdminKycRepository repository;

  KycNotifier({AdminKycRepository? repository})
      : repository = repository ?? AdminKycRepository(),
        super(const KycState(applications: [], isLoading: true)) {
    loadApplications();
  }

  Future<void> loadApplications() async {
    state = state.copyWith(isLoading: true);
    final list = await repository.getApplications(
      status: state.selectedStatus,
      role: state.selectedRole,
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(applications: list, isLoading: false);
  }

  Future<void> setStatusFilter(KycStatus? status) async {
    if (state.selectedStatus == status) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
    await loadApplications();
  }

  Future<void> setRoleFilter(UserRole? role) async {
    if (state.selectedRole == role) {
      state = state.copyWith(clearRole: true);
    } else {
      state = state.copyWith(selectedRole: role);
    }
    await loadApplications();
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadApplications();
  }

  Future<bool> approve(String id) async {
    final success = await repository.approveApplication(id);
    if (success) {
      state = state.copyWith(actionMessage: 'Application $id approved successfully!');
      await loadApplications();
    }
    return success;
  }

  Future<bool> reject(String id, String reason) async {
    final success = await repository.rejectApplication(id, reason: reason);
    if (success) {
      state = state.copyWith(actionMessage: 'Application $id rejected.');
      await loadApplications();
    }
    return success;
  }
}

final adminKycRepoProvider = Provider<AdminKycRepository>((ref) {
  return AdminKycRepository();
});

final kycProvider = StateNotifierProvider<KycNotifier, KycState>((ref) {
  final repo = ref.watch(adminKycRepoProvider);
  return KycNotifier(repository: repo);
});

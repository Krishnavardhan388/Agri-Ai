import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/admin_dispatch_repository.dart';
import '../domain/admin_dispatch_trip.dart';

class DispatchState {
  final List<AdminDispatchTrip> trips;
  final bool isLoading;
  final DispatchStatus? selectedStatus;
  final String searchQuery;
  final String? actionMessage;

  const DispatchState({
    required this.trips,
    this.isLoading = false,
    this.selectedStatus,
    this.searchQuery = '',
    this.actionMessage,
  });

  DispatchState copyWith({
    List<AdminDispatchTrip>? trips,
    bool? isLoading,
    DispatchStatus? selectedStatus,
    bool clearStatus = false,
    String? searchQuery,
    String? actionMessage,
  }) {
    return DispatchState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  int get activeInTransitCount => trips.where((t) => t.status == DispatchStatus.inTransit || t.status == DispatchStatus.pickedUp).length;
  int get disputedCount => trips.where((t) => t.status == DispatchStatus.disputed).length;
}

class DispatchNotifier extends StateNotifier<DispatchState> {
  final AdminDispatchRepository repository;

  DispatchNotifier({AdminDispatchRepository? repository})
      : repository = repository ?? AdminDispatchRepository(),
        super(const DispatchState(trips: [], isLoading: true)) {
    loadTrips();
  }

  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true);
    final list = await repository.getTrips(
      status: state.selectedStatus,
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(trips: list, isLoading: false);
  }

  Future<void> setStatusFilter(DispatchStatus? status) async {
    if (state.selectedStatus == status) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
    await loadTrips();
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadTrips();
  }

  Future<bool> reassignDriver({
    required String tripId,
    required String newDriverName,
    required String newDriverPhone,
    required String newDriverVehicle,
  }) async {
    final success = await repository.reassignDriver(
      tripId,
      newDriverName: newDriverName,
      newDriverPhone: newDriverPhone,
      newDriverVehicle: newDriverVehicle,
    );
    if (success) {
      state = state.copyWith(actionMessage: 'Trip $tripId reassigned to $newDriverName!');
      await loadTrips();
    }
    return success;
  }

  Future<bool> overrideVerifyOtp(String tripId) async {
    final success = await repository.overrideVerifyOtp(tripId);
    if (success) {
      state = state.copyWith(actionMessage: 'Trip $tripId marked as Delivered via Admin Override.');
      await loadTrips();
    }
    return success;
  }
}

final adminDispatchRepoProvider = Provider<AdminDispatchRepository>((ref) {
  return AdminDispatchRepository(apiClient: ref.watch(apiClientProvider));
});

final dispatchProvider = StateNotifierProvider<DispatchNotifier, DispatchState>((ref) {
  final repo = ref.watch(adminDispatchRepoProvider);
  return DispatchNotifier(repository: repo);
});

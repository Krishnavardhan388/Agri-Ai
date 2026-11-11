import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/delivery_repository.dart';
import '../data/map_navigation_service.dart';
import '../domain/delivery_task_model.dart';

class DeliveryState {
  final bool isOnline;
  final List<DeliveryTask> tasks;
  final double walletBalance;
  final int tripsCompletedToday;
  final List<DeliveryWalletRecord> transactions;
  final bool isLoading;
  final String? errorMessage;
  final String? lastSuccessAction;

  const DeliveryState({
    this.isOnline = true,
    this.tasks = const [],
    this.walletBalance = 1180.0,
    this.tripsCompletedToday = 11,
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastSuccessAction,
  });

  List<DeliveryTask> get activeTasks => tasks
      .where((t) =>
          t.status == DeliveryTaskStatus.accepted ||
          t.status == DeliveryTaskStatus.pickedUp)
      .toList();

  List<DeliveryTask> get availableTasks =>
      tasks.where((t) => t.status == DeliveryTaskStatus.available).toList();

  List<DeliveryTask> get completedTasks =>
      tasks.where((t) => t.status == DeliveryTaskStatus.delivered).toList();

  double get todayEarnings {
    double total = 0;
    for (final t in transactions) {
      if (t.isCredit) {
        total += t.amount;
      }
    }
    return total;
  }

  DeliveryState copyWith({
    bool? isOnline,
    List<DeliveryTask>? tasks,
    double? walletBalance,
    int? tripsCompletedToday,
    List<DeliveryWalletRecord>? transactions,
    bool? isLoading,
    String? errorMessage,
    String? lastSuccessAction,
  }) {
    return DeliveryState(
      isOnline: isOnline ?? this.isOnline,
      tasks: tasks ?? this.tasks,
      walletBalance: walletBalance ?? this.walletBalance,
      tripsCompletedToday: tripsCompletedToday ?? this.tripsCompletedToday,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastSuccessAction: lastSuccessAction,
    );
  }
}

class DeliveryNotifier extends StateNotifier<DeliveryState> {
  final DeliveryRepository repository;
  final MapNavigationService navService;

  DeliveryNotifier({
    required this.repository,
    required this.navService,
  }) : super(const DeliveryState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tasks = await repository.getTasks();
      final balance = await repository.getWalletBalance();
      final trips = await repository.getTripsCompletedCount();
      final txns = await repository.getTransactions();

      state = state.copyWith(
        tasks: tasks,
        walletBalance: balance,
        tripsCompletedToday: trips,
        transactions: txns,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load delivery assignments: $e',
      );
    }
  }

  void toggleOnline(bool online) {
    state = state.copyWith(isOnline: online);
  }

  Future<bool> acceptTrip(String taskId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final updated = await repository.acceptTask(taskId);
    if (updated != null) {
      await loadData();
      state = state.copyWith(
        lastSuccessAction: 'Trip accepted! Proceed to farm for harvest pickup.',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to accept trip. It may already be assigned.',
      );
      return false;
    }
  }

  Future<bool> markPickedUp(String taskId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final updated = await repository.markTaskPickedUp(taskId);
    if (updated != null) {
      await loadData();
      state = state.copyWith(
        lastSuccessAction: 'Harvest picked up! Navigate to customer drop location.',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update pickup status.',
      );
      return false;
    }
  }

  Future<bool> verifyOtpAndDeliver(String taskId, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final success = await repository.verifyAndCompleteTask(taskId, otp);
    if (success) {
      await loadData();
      state = state.copyWith(
        lastSuccessAction: 'Delivery verified! Payment credited to your wallet.',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid OTP code. Please check with customer.',
      );
      return false;
    }
  }

  Future<bool> requestBankPayout(double amount, String upiOrBank) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final success = await repository.requestBankPayout(amount, upiOrBank);
    if (success) {
      await loadData();
      state = state.copyWith(
        lastSuccessAction: 'Payout request of ₹$amount initiated successfully!',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Insufficient wallet balance or invalid amount.',
      );
      return false;
    }
  }

  Future<bool> launchNavigation({
    required double lat,
    required double lng,
    String? label,
  }) async {
    return await navService.launchMapsNavigation(lat: lat, lng: lng, label: label);
  }

  Future<bool> launchPhone(String phone) async {
    return await navService.launchPhoneCall(phone);
  }
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(apiClient: ref.watch(apiClientProvider));
});

final mapNavigationServiceProvider = Provider<MapNavigationService>((ref) {
  return const MapNavigationService();
});

final deliveryProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  final nav = ref.watch(mapNavigationServiceProvider);
  return DeliveryNotifier(repository: repo, navService: nav);
});


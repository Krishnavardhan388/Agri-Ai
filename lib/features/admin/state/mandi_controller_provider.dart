import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/admin_mandi_controller_repository.dart';
import '../domain/admin_mandi_update.dart';

class MandiControllerState {
  final List<AdminMandiCropRate> rates;
  final bool isLoading;
  final String? actionMessage;

  const MandiControllerState({
    required this.rates,
    this.isLoading = false,
    this.actionMessage,
  });

  MandiControllerState copyWith({
    List<AdminMandiCropRate>? rates,
    bool? isLoading,
    String? actionMessage,
  }) {
    return MandiControllerState(
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }
}

class MandiControllerNotifier extends StateNotifier<MandiControllerState> {
  final AdminMandiControllerRepository repository;

  MandiControllerNotifier({AdminMandiControllerRepository? repository})
      : repository = repository ?? AdminMandiControllerRepository(),
        super(const MandiControllerState(rates: [], isLoading: true)) {
    loadRates();
  }

  Future<void> loadRates() async {
    state = state.copyWith(isLoading: true);
    final items = await repository.getRates();
    state = state.copyWith(rates: items, isLoading: false);
  }

  Future<bool> updateRate(
    String id,
    double newModalPrice, {
    double? minPrice,
    double? maxPrice,
  }) async {
    final success = await repository.updateRate(
      id,
      newModalPrice,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    if (success) {
      state = state.copyWith(actionMessage: 'Floor price updated to ₹${newModalPrice.toInt()}/Qtl.');
      await loadRates();
    }
    return success;
  }

  Future<bool> broadcastRate(String id) async {
    final success = await repository.broadcastRateToFarmers(id);
    if (success) {
      final rate = state.rates.firstWhere((r) => r.id == id);
      state = state.copyWith(
        actionMessage: 'Broadcast sent to farmers: ${rate.cropName} is ₹${rate.modalPricePerQuintal.toInt()}/Qtl.',
      );
      await loadRates();
    }
    return success;
  }
}

final adminMandiRepoProvider = Provider<AdminMandiControllerRepository>((ref) {
  return AdminMandiControllerRepository(apiClient: ref.watch(apiClientProvider));
});

final mandiControllerProvider = StateNotifierProvider<MandiControllerNotifier, MandiControllerState>((ref) {
  final repo = ref.watch(adminMandiRepoProvider);
  return MandiControllerNotifier(repository: repo);
});

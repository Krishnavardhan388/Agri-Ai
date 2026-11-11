import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/admin_marketplace_repository.dart';
import '../domain/admin_marketplace_item.dart';

class MarketplaceModerationState {
  final List<AdminProductItem> products;
  final bool isLoading;
  final ProductModerationStatus? selectedStatus;
  final String searchQuery;
  final bool onlyOrganic;
  final String? actionMessage;

  const MarketplaceModerationState({
    required this.products,
    this.isLoading = false,
    this.selectedStatus,
    this.searchQuery = '',
    this.onlyOrganic = false,
    this.actionMessage,
  });

  MarketplaceModerationState copyWith({
    List<AdminProductItem>? products,
    bool? isLoading,
    ProductModerationStatus? selectedStatus,
    bool clearStatus = false,
    String? searchQuery,
    bool? onlyOrganic,
    String? actionMessage,
  }) {
    return MarketplaceModerationState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      onlyOrganic: onlyOrganic ?? this.onlyOrganic,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  int get anomalyCount => products.where((p) => p.hasHighDeviation || p.status == ProductModerationStatus.priceAlert).length;
}

class MarketplaceModerationNotifier extends StateNotifier<MarketplaceModerationState> {
  final AdminMarketplaceRepository repository;

  MarketplaceModerationNotifier({AdminMarketplaceRepository? repository})
      : repository = repository ?? AdminMarketplaceRepository(),
        super(const MarketplaceModerationState(products: [], isLoading: true)) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true);
    final items = await repository.getProducts(
      status: state.selectedStatus,
      searchQuery: state.searchQuery,
      onlyOrganic: state.onlyOrganic ? true : null,
    );
    state = state.copyWith(products: items, isLoading: false);
  }

  Future<void> setStatusFilter(ProductModerationStatus? status) async {
    if (state.selectedStatus == status) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
    await loadProducts();
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadProducts();
  }

  Future<void> toggleOrganicFilter() async {
    state = state.copyWith(onlyOrganic: !state.onlyOrganic);
    await loadProducts();
  }

  Future<bool> approveListing(String id) async {
    final success = await repository.updateProductStatus(id, ProductModerationStatus.active);
    if (success) {
      state = state.copyWith(actionMessage: 'Listing $id approved and verified!');
      await loadProducts();
    }
    return success;
  }

  Future<bool> flagPriceWarning(String id, String note) async {
    final success = await repository.updateProductStatus(
      id,
      ProductModerationStatus.priceAlert,
      note: note,
    );
    if (success) {
      state = state.copyWith(actionMessage: 'Price anomaly alert sent to farmer for $id.');
      await loadProducts();
    }
    return success;
  }

  Future<bool> unlistListing(String id) async {
    final success = await repository.updateProductStatus(id, ProductModerationStatus.unlisted);
    if (success) {
      state = state.copyWith(actionMessage: 'Listing $id paused / unlisted from marketplace.');
      await loadProducts();
    }
    return success;
  }

  Future<bool> updateStock(String id, double stockKg) async {
    final success = await repository.updateStock(id, stockKg);
    if (success) {
      state = state.copyWith(actionMessage: 'Stock updated to $stockKg kg for $id.');
      await loadProducts();
    }
    return success;
  }

  Future<bool> toggleOrganic(String id) async {
    final success = await repository.toggleOrganicStatus(id);
    if (success) {
      state = state.copyWith(actionMessage: 'Organic certification tag updated.');
      await loadProducts();
    }
    return success;
  }
}

final adminMarketplaceRepoProvider = Provider<AdminMarketplaceRepository>((ref) {
  return AdminMarketplaceRepository(apiClient: ref.watch(apiClientProvider));
});

final marketplaceModerationProvider = StateNotifierProvider<MarketplaceModerationNotifier, MarketplaceModerationState>((ref) {
  final repo = ref.watch(adminMarketplaceRepoProvider);
  return MarketplaceModerationNotifier(repository: repo);
});

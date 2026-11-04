import '../domain/admin_marketplace_item.dart';

class AdminMarketplaceRepository {
  final List<AdminProductItem> _items = [
    const AdminProductItem(
      id: 'prod-tomato-1',
      farmerName: 'Ramesh Kumar',
      farmerLocation: 'Warangal, Telangana',
      title: 'Fresh Organic Red Tomatoes',
      category: 'Vegetables',
      pricePerKg: 35.0,
      mandiBenchmarkPerKg: 28.0,
      stockKg: 150.0,
      isOrganic: true,
      status: ProductModerationStatus.active,
    ),
    const AdminProductItem(
      id: 'prod-rice-2',
      farmerName: 'Ramesh Kumar',
      farmerLocation: 'Warangal, Telangana',
      title: 'Sona Masoori Raw Rice (A-Grade)',
      category: 'Grains & Cereals',
      pricePerKg: 55.0,
      mandiBenchmarkPerKg: 50.0,
      stockKg: 500.0,
      isOrganic: true,
      status: ProductModerationStatus.active,
    ),
    const AdminProductItem(
      id: 'prod-cotton-5',
      farmerName: 'Telangana Cotton Producers FPO',
      farmerLocation: 'Adilabad, Telangana',
      title: 'Raw Cotton (Shankar 6 Medium Staple)',
      category: 'Commercial Crops',
      pricePerKg: 72.0,
      mandiBenchmarkPerKg: 71.2,
      stockKg: 800.0,
      isOrganic: false,
      status: ProductModerationStatus.active,
    ),
    const AdminProductItem(
      id: 'prod-chilli-6',
      farmerName: 'Rayalaseema Natural Farms',
      farmerLocation: 'Khammam, Telangana',
      title: 'Organic Guntur Teja Red Chilli',
      category: 'Spices',
      pricePerKg: 180.0,
      mandiBenchmarkPerKg: 185.0,
      stockKg: 60.0,
      isOrganic: true,
      status: ProductModerationStatus.active,
    ),
    const AdminProductItem(
      id: 'prod-onion-4',
      farmerName: 'Kisan Bandhu Farms',
      farmerLocation: 'Medak, Telangana',
      title: 'Fresh Red Onions (Premium)',
      category: 'Vegetables',
      pricePerKg: 48.0,
      mandiBenchmarkPerKg: 28.0,
      stockKg: 250.0,
      isOrganic: false,
      status: ProductModerationStatus.priceAlert,
      moderationNote: 'Farmer asking price (₹48/kg) is 71.4% higher than Malakpet Mandi floor rate (₹28/kg).',
    ),
    const AdminProductItem(
      id: 'prod-capsicum-3',
      farmerName: 'Sri Krishna Organic Farm',
      farmerLocation: 'Karimnagar, Telangana',
      title: 'Green Bell Pepper / Capsicum',
      category: 'Vegetables',
      pricePerKg: 48.0,
      mandiBenchmarkPerKg: 42.0,
      stockKg: 80.0,
      isOrganic: true,
      status: ProductModerationStatus.active,
    ),
  ];

  Future<List<AdminProductItem>> getProducts({
    ProductModerationStatus? status,
    String? searchQuery,
    bool? onlyOrganic,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _items.where((p) {
      if (status != null && p.status != status) {
        return false;
      }
      if (onlyOrganic == true && !p.isOrganic) {
        return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesFarmer = p.farmerName.toLowerCase().contains(query);
        final matchesCategory = p.category.toLowerCase().contains(query);
        final matchesLocation = p.farmerLocation.toLowerCase().contains(query);
        if (!matchesTitle && !matchesFarmer && !matchesCategory && !matchesLocation) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<bool> updateProductStatus(
    String id,
    ProductModerationStatus status, {
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _items.indexWhere((p) => p.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        status: status,
        moderationNote: note,
      );
      return true;
    }
    return false;
  }

  Future<bool> updateStock(String id, double newStockKg) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _items.indexWhere((p) => p.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        stockKg: newStockKg,
        status: newStockKg <= 0 ? ProductModerationStatus.outOfStock : _items[index].status,
      );
      return true;
    }
    return false;
  }

  Future<bool> toggleOrganicStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _items.indexWhere((p) => p.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        isOrganic: !_items[index].isOrganic,
      );
      return true;
    }
    return false;
  }

  int getPriceAnomalyCount() {
    return _items.where((p) => p.hasHighDeviation || p.status == ProductModerationStatus.priceAlert).length;
  }
}

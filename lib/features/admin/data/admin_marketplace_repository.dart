import '../../../core/services/api_client.dart';
import '../domain/admin_marketplace_item.dart';

class AdminMarketplaceRepository {
  final ApiClient _apiClient;

  AdminMarketplaceRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

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

  AdminProductItem _fromApi(Map<String, dynamic> map) {
    ProductModerationStatus parsed = ProductModerationStatus.active;
    try {
      parsed = ProductModerationStatus.values.byName(map['status']?.toString() ?? 'active');
    } catch (_) {}

    return AdminProductItem(
      id: map['id']?.toString() ?? '',
      farmerName: map['farmer_name']?.toString() ?? 'Partner Farmer',
      farmerLocation: map['farmer_location']?.toString() ?? 'Telangana',
      title: map['name']?.toString() ?? 'Farm Produce',
      category: map['category']?.toString() ?? 'Vegetables',
      pricePerKg: (map['price_per_kg'] as num?)?.toDouble() ?? 35.0,
      mandiBenchmarkPerKg: (map['mandi_benchmark'] as num?)?.toDouble() ?? 32.0,
      stockKg: (map['available_kg'] as num?)?.toDouble() ?? 0.0,
      isOrganic: map['is_organic'] == true,
      status: parsed,
      moderationNote: map['moderation_note']?.toString(),
    );
  }

  Future<List<AdminProductItem>> getProducts({
    ProductModerationStatus? status,
    String? searchQuery,
    bool? onlyOrganic,
  }) async {
    List<AdminProductItem> source = _items;
    try {
      final resp = await _apiClient.get('/api/v1/marketplace/products');
      if (resp is List && resp.isNotEmpty) {
        source = resp.whereType<Map>().map((e) => _fromApi(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}

    return source.where((p) {
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
    try {
      await _apiClient.patch(
        '/api/v1/marketplace/products/$id',
        body: {'status': status.name, 'moderation_note': ?note},
      );
      return true;
    } catch (_) {}

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
    try {
      await _apiClient.patch(
        '/api/v1/marketplace/products/$id',
        body: {'available_kg': newStockKg},
      );
      return true;
    } catch (_) {}

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
    final index = _items.indexWhere((p) => p.id == id);
    bool nextVal = true;
    if (index != -1) {
      nextVal = !_items[index].isOrganic;
      _items[index] = _items[index].copyWith(isOrganic: nextVal);
    }

    try {
      await _apiClient.patch(
        '/api/v1/marketplace/products/$id',
        body: {'is_organic': nextVal},
      );
      return true;
    } catch (_) {}

    return index != -1;
  }

  int getPriceAnomalyCount() {
    return _items.where((p) => p.hasHighDeviation || p.status == ProductModerationStatus.priceAlert).length;
  }
}

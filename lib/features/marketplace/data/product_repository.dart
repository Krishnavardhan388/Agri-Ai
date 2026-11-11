import '../../../core/services/api_client.dart';
import '../domain/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  final List<ProductModel> _localCatalog = [
    const ProductModel(
      id: 'PROD-101',
      farmerId: 'user-farmer-ramesh',
      farmerName: 'Ramesh Farm, Warangal',
      farmerLocation: 'Village Nallabelli (3.2 km)',
      title: 'Fresh Organic Tomatoes',
      description: 'Plump, naturally vine-ripened red tomatoes. Zero chemical sprays, pure organic manure.',
      category: 'Vegetables',
      pricePerKg: 35.0,
      originalPricePerKg: 48.0,
      availableStockKg: 450.0,
      harvestDate: 'Harvested 1 day ago',
      rating: 4.8,
      totalReviews: 82,
      isOrganic: true,
    ),
    const ProductModel(
      id: 'PROD-102',
      farmerId: 'user-farmer-ramesh',
      farmerName: 'Krishna Valley Farms',
      farmerLocation: 'Parkal, Warangal (14 km)',
      title: 'Sona Masoori Raw Rice',
      description: 'Single-origin premium BPT 5204 aged rice. High aroma, slender grain, pesticide-free harvest.',
      category: 'Grains & Pulses',
      pricePerKg: 55.0,
      originalPricePerKg: 68.0,
      availableStockKg: 2000.0,
      harvestDate: 'Current Season Harvest',
      rating: 4.9,
      totalReviews: 140,
      isOrganic: true,
    ),
    const ProductModel(
      id: 'PROD-104',
      farmerId: 'farmer-govind',
      farmerName: 'Govind Rao Farms',
      farmerLocation: 'Hanamkonda Rural (5 km)',
      title: 'Organic Red Onions (Pyaz)',
      description: 'Crisp medium Garwa variety onions with natural pungent flavour and long shelf-life.',
      category: 'Vegetables',
      pricePerKg: 28.0,
      originalPricePerKg: 38.0,
      availableStockKg: 600.0,
      harvestDate: 'Harvested 3 days ago',
      rating: 4.7,
      totalReviews: 55,
      isOrganic: true,
    ),
    const ProductModel(
      id: 'PROD-105',
      farmerId: 'user-farmer-ramesh',
      farmerName: 'Ramesh Farm, Warangal',
      farmerLocation: 'Village Nallabelli (3.2 km)',
      title: 'Premium Raw Cotton (Kapas)',
      description: 'Medium staple high-strength cotton bolls ready for ginning and textile use.',
      category: 'Cash Crops',
      pricePerKg: 75.0,
      originalPricePerKg: 85.0,
      availableStockKg: 800.0,
      harvestDate: 'Harvested 1 week ago',
      rating: 4.9,
      totalReviews: 32,
      isOrganic: false,
    ),
  ];

  ProductRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  ProductModel _fromApiMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      farmerId: map['farmer_id']?.toString() ?? 'user-farmer-ramesh',
      farmerName: map['farmer_name']?.toString() ?? 'Ramesh Farm',
      farmerLocation: map['farmer_location']?.toString() ?? 'Warangal',
      title: map['name']?.toString() ?? map['title']?.toString() ?? 'Farm Produce',
      description: map['description']?.toString() ?? 'Fresh harvest directly from farm.',
      category: map['category']?.toString() ?? 'Vegetables',
      pricePerKg: (map['price_per_kg'] as num?)?.toDouble() ?? 35.0,
      originalPricePerKg: (map['mandi_benchmark'] as num?)?.toDouble() ?? 45.0,
      availableStockKg: (map['available_kg'] as num?)?.toDouble() ?? 100.0,
      harvestDate: map['harvest_date']?.toString() ?? 'Harvested Today',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      totalReviews: (map['review_count'] as num?)?.toInt() ?? 1,
      isOrganic: map['is_organic'] == true,
    );
  }

  Future<List<ProductModel>> getProducts({String category = 'All', String query = ''}) async {
    try {
      final params = <String, String>{};
      if (category.isNotEmpty && category != 'All' && category != 'All Items') {
        params['category'] = category;
      }
      if (query.trim().isNotEmpty) {
        params['q'] = query.trim();
      }

      final resp = await _apiClient.get('/api/v1/marketplace/products', queryParameters: params);
      if (resp is List) {
        final cloudProducts = resp
            .whereType<Map>()
            .map((e) => _fromApiMap(Map<String, dynamic>.from(e)))
            .toList();
        return cloudProducts;
      }
    } catch (_) {}

    return _filterList(_localCatalog, category, query);
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    _localCatalog.insert(0, product);

    try {
      final resp = await _apiClient.post(
        '/api/v1/marketplace/products',
        body: {
          'name': product.title,
          'description': product.description,
          'category': product.category,
          'price_per_kg': product.pricePerKg,
          'mandi_benchmark': product.originalPricePerKg,
          'available_kg': product.availableStockKg,
          'farmer_id': product.farmerId,
          'farmer_name': product.farmerName,
          'farmer_location': product.farmerLocation,
          'farmer_phone': '+91 98765 43210',
          'harvest_date': product.harvestDate,
          'is_organic': product.isOrganic,
        },
      );
      if (resp is Map<String, dynamic>) {
        return _fromApiMap(resp);
      }
    } catch (_) {}

    return product;
  }

  List<ProductModel> _filterList(List<ProductModel> list, String category, String query) {
    return list.where((item) {
      final matchesCat = category == 'All' || category == 'All Items' || item.category == category;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.farmerName.toLowerCase().contains(query.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }
}

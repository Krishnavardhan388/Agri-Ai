import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/product_model.dart';

class ProductRepository {
  FirebaseFirestore? _firestore;

  final List<ProductModel> _localCatalog = [
    const ProductModel(
      id: 'prod-tomato-1',
      farmerId: 'farmer-ramesh',
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
      id: 'prod-rice-2',
      farmerId: 'farmer-krishna',
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
      id: 'prod-onion-3',
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
      id: 'prod-cotton-4',
      farmerId: 'farmer-ramesh',
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

  ProductRepository({FirebaseFirestore? firestore}) {
    if (firestore != null) _firestore = firestore;
  }

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    if (FirebaseService.isInitialized) {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    }
    return null;
  }

  Future<List<ProductModel>> getProducts({String category = 'All', String query = ''}) async {
    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        final snapshot = await fs.collection('products').get();
        if (snapshot.docs.isNotEmpty) {
          final cloudProducts = snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList();

          return _filterList(cloudProducts, category, query);
        }
      } catch (_) {}
    }

    return _filterList(_localCatalog, category, query);
  }

  Future<void> addProduct(ProductModel product) async {
    _localCatalog.insert(0, product);

    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        await fs.collection('products').doc(product.id).set(product.toMap());
      } catch (_) {}
    }
  }

  List<ProductModel> _filterList(List<ProductModel> list, String category, String query) {
    return list.where((item) {
      final matchesCat = category == 'All' || item.category == category;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.farmerName.toLowerCase().contains(query.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }
}


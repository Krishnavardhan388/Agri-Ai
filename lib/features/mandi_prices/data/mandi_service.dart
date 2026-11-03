import '../domain/mandi_crop_model.dart';

class MandiService {
  final List<MandiCropItem> _allMandiCrops = [
    MandiCropItem(
      id: 'mandi-cotton',
      cropName: 'Cotton (Kapas)',
      variety: 'Medium Staple (Kapas)',
      category: 'Cash Crops',
      marketName: 'Warangal APMC Mandi',
      distanceKm: 3.8,
      minPrice: 6850,
      maxPrice: 7420,
      modalPrice: 7250,
      priceChange: 150,
      isPriceUp: true,
      lastUpdated: DateTime.now(),
    ),
    MandiCropItem(
      id: 'mandi-paddy',
      cropName: 'Paddy / Rice (Dhan)',
      variety: 'BPT 5204 (Sona Masoori)',
      category: 'Cereals',
      marketName: 'Warangal APMC Mandi',
      distanceKm: 3.8,
      minPrice: 2240,
      maxPrice: 2420,
      modalPrice: 2380,
      priceChange: 40,
      isPriceUp: true,
      lastUpdated: DateTime.now(),
    ),
    MandiCropItem(
      id: 'mandi-chilli',
      cropName: 'Red Chilli (Mirchi)',
      variety: 'Teja Superior',
      category: 'Spices',
      marketName: 'Enumamula Grain Market',
      distanceKm: 5.2,
      minPrice: 17200,
      maxPrice: 19800,
      modalPrice: 18500,
      priceChange: 200,
      isPriceUp: false,
      lastUpdated: DateTime.now(),
    ),
    MandiCropItem(
      id: 'mandi-maize',
      cropName: 'Maize (Makka)',
      variety: 'Yellow Hybrid',
      category: 'Cereals',
      marketName: 'Warangal APMC Mandi',
      distanceKm: 3.8,
      minPrice: 1950,
      maxPrice: 2180,
      modalPrice: 2120,
      priceChange: 35,
      isPriceUp: true,
      lastUpdated: DateTime.now(),
    ),
    MandiCropItem(
      id: 'mandi-turmeric',
      cropName: 'Turmeric (Haldi)',
      variety: 'Selam / Finger',
      category: 'Spices',
      marketName: 'Kesamudram Mandi',
      distanceKm: 18.4,
      minPrice: 12500,
      maxPrice: 14200,
      modalPrice: 13600,
      priceChange: 350,
      isPriceUp: true,
      lastUpdated: DateTime.now(),
    ),
    MandiCropItem(
      id: 'mandi-tomato',
      cropName: 'Fresh Tomato',
      variety: 'Desi Hybrid',
      category: 'Vegetables',
      marketName: 'Subedari Rythu Bazar',
      distanceKm: 2.1,
      minPrice: 2800,
      maxPrice: 3800,
      modalPrice: 3500,
      priceChange: 250,
      isPriceUp: true,
      lastUpdated: DateTime.now(),
    ),
    MandiCropItem(
      id: 'mandi-onion',
      cropName: 'Red Onion (Pyaz)',
      variety: 'Medium Garwa',
      category: 'Vegetables',
      marketName: 'Warangal APMC Mandi',
      distanceKm: 3.8,
      minPrice: 2200,
      maxPrice: 3000,
      modalPrice: 2800,
      priceChange: 100,
      isPriceUp: false,
      lastUpdated: DateTime.now(),
    ),
  ];

  Future<List<MandiCropItem>> getMandiRates({
    String query = '',
    String category = 'All',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _allMandiCrops.where((item) {
      final matchesQuery = query.isEmpty ||
          item.cropName.toLowerCase().contains(query.toLowerCase()) ||
          item.variety.toLowerCase().contains(query.toLowerCase());

      final matchesCategory = category == 'All' || item.category == category;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<List<MandiComparisonItem>> compareCropAcrossMandis(String cropName) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (cropName.contains('Cotton')) {
      return const [
        MandiComparisonItem(
          mandiName: 'Warangal APMC Mandi',
          district: 'Warangal (3.8 km)',
          distanceKm: 3.8,
          modalPricePerQuintal: 7250,
          isHighestPrice: false,
        ),
        MandiComparisonItem(
          mandiName: 'Enumamula Cotton Market',
          district: 'Warangal Rural (7.1 km)',
          distanceKm: 7.1,
          modalPricePerQuintal: 7420,
          isHighestPrice: true,
        ),
        MandiComparisonItem(
          mandiName: 'Jangaon APMC Yard',
          district: 'Jangaon (42 km)',
          distanceKm: 42.0,
          modalPricePerQuintal: 7180,
          isHighestPrice: false,
        ),
      ];
    }

    if (cropName.contains('Chilli')) {
      return const [
        MandiComparisonItem(
          mandiName: 'Enumamula Red Chilli Yard',
          district: 'Warangal (5.2 km)',
          distanceKm: 5.2,
          modalPricePerQuintal: 18500,
          isHighestPrice: false,
        ),
        MandiComparisonItem(
          mandiName: 'Khammam APMC Chilli Market',
          district: 'Khammam (85 km)',
          distanceKm: 85.0,
          modalPricePerQuintal: 19200,
          isHighestPrice: true,
        ),
        MandiComparisonItem(
          mandiName: 'Guntur Mirchi Yard',
          district: 'Guntur (190 km)',
          distanceKm: 190.0,
          modalPricePerQuintal: 19600,
          isHighestPrice: false,
        ),
      ];
    }

    // Default comparison for Paddy & others
    return const [
      MandiComparisonItem(
        mandiName: 'Warangal APMC Mandi',
        district: 'Warangal (3.8 km)',
        distanceKm: 3.8,
        modalPricePerQuintal: 2380,
        isHighestPrice: false,
      ),
      MandiComparisonItem(
        mandiName: 'Karimnagar Grain Mandi',
        district: 'Karimnagar (68 km)',
        distanceKm: 68.0,
        modalPricePerQuintal: 2450,
        isHighestPrice: true,
      ),
      MandiComparisonItem(
        mandiName: 'Nalgonda APMC Market',
        district: 'Nalgonda (110 km)',
        distanceKm: 110.0,
        modalPricePerQuintal: 2350,
        isHighestPrice: false,
      ),
    ];
  }
}


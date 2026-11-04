import '../domain/admin_mandi_update.dart';

class AdminMandiControllerRepository {
  final List<AdminMandiCropRate> _rates = [
    AdminMandiCropRate(
      id: 'mandi-cotton-1',
      cropName: 'Cotton (Medium Staple)',
      marketName: 'Warangal APMC Mandi',
      district: 'Warangal',
      modalPricePerQuintal: 7120.0,
      minPricePerQuintal: 6800.0,
      maxPricePerQuintal: 7450.0,
      trendPercentage: 2.1,
      isRising: true,
      lastBroadcastAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AdminMandiCropRate(
      id: 'mandi-paddy-2',
      cropName: 'Paddy (Sona Masoori Grade A)',
      marketName: 'Karimnagar Market Yard',
      district: 'Karimnagar',
      modalPricePerQuintal: 2380.0,
      minPricePerQuintal: 2250.0,
      maxPricePerQuintal: 2450.0,
      trendPercentage: 1.2,
      isRising: true,
      lastBroadcastAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AdminMandiCropRate(
      id: 'mandi-chilli-3',
      cropName: 'Red Chilli (Teja Super Hot)',
      marketName: 'Khammam Agricultural Market',
      district: 'Khammam',
      modalPricePerQuintal: 18500.0,
      minPricePerQuintal: 16800.0,
      maxPricePerQuintal: 19800.0,
      trendPercentage: 1.8,
      isRising: true,
      lastBroadcastAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    AdminMandiCropRate(
      id: 'mandi-tomato-4',
      cropName: 'Tomato (Hybrid Desi)',
      marketName: 'Bowenpally APMC Market',
      district: 'Hyderabad',
      modalPricePerQuintal: 2800.0,
      minPricePerQuintal: 2400.0,
      maxPricePerQuintal: 3100.0,
      trendPercentage: -4.5,
      isRising: false,
      lastBroadcastAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    AdminMandiCropRate(
      id: 'mandi-onion-5',
      cropName: 'Red Onion (Grade 1)',
      marketName: 'Malakpet Wholesale Mandi',
      district: 'Hyderabad',
      modalPricePerQuintal: 2800.0,
      minPricePerQuintal: 2500.0,
      maxPricePerQuintal: 3200.0,
      trendPercentage: 3.0,
      isRising: true,
      lastBroadcastAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  Future<List<AdminMandiCropRate>> getRates() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_rates);
  }

  Future<bool> updateRate(
    String id,
    double newModalPrice, {
    double? minPrice,
    double? maxPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _rates.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _rates[index];
      final change = newModalPrice - old.modalPricePerQuintal;
      final pct = (change / old.modalPricePerQuintal) * 100.0;

      _rates[index] = old.copyWith(
        modalPricePerQuintal: newModalPrice,
        minPricePerQuintal: minPrice ?? (newModalPrice * 0.94),
        maxPricePerQuintal: maxPrice ?? (newModalPrice * 1.06),
        trendPercentage: double.parse(pct.toStringAsFixed(1)),
        isRising: change >= 0,
        lastBroadcastAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  Future<bool> broadcastRateToFarmers(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _rates.indexWhere((r) => r.id == id);
    if (index != -1) {
      _rates[index] = _rates[index].copyWith(lastBroadcastAt: DateTime.now());
      return true;
    }
    return false;
  }
}

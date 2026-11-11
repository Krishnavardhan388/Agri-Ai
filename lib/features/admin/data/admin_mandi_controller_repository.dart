import '../../../core/services/api_client.dart';
import '../domain/admin_mandi_update.dart';

class AdminMandiControllerRepository {
  final ApiClient _apiClient;

  AdminMandiControllerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

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
    try {
      final resp = await _apiClient.get('/api/v1/mandi/rates');
      if (resp is List && resp.isNotEmpty) {
        return resp.whereType<Map>().map((m) {
          final trend = m['trend']?.toString() ?? 'up';
          return AdminMandiCropRate(
            id: m['id']?.toString() ?? '',
            cropName: m['crop_name']?.toString() ?? '',
            marketName: m['market_yard']?.toString() ?? 'APMC Yard',
            district: m['market_yard']?.toString().split(' ').first ?? 'Telangana',
            modalPricePerQuintal: (m['modal_price'] as num?)?.toDouble() ?? 0.0,
            minPricePerQuintal: (m['min_price'] as num?)?.toDouble() ?? 0.0,
            maxPricePerQuintal: (m['max_price'] as num?)?.toDouble() ?? 0.0,
            trendPercentage: (m['price_change'] as num?)?.toDouble() ?? 1.5,
            isRising: trend.toLowerCase() != 'down',
            lastBroadcastAt: DateTime.tryParse(m['last_updated']?.toString() ?? '') ?? DateTime.now(),
          );
        }).toList();
      }
    } catch (_) {}
    return List.unmodifiable(_rates);
  }

  Future<bool> updateRate(
    String id,
    double newModalPrice, {
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      await _apiClient.put(
        '/api/v1/mandi/rates/$id',
        body: {
          'modal_price': newModalPrice,
          'min_price': ?minPrice,
          'max_price': ?maxPrice,
        },
      );
      return true;
    } catch (_) {}

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
    try {
      await _apiClient.post(
        '/api/v1/admin/broadcasts',
        body: {
          'district': 'All Telangana Mandis',
          'crop': id,
          'advisory': 'Updated official APMC rate benchmark ($id) published to AGRI AI Marketplaces.',
        },
      );
      return true;
    } catch (_) {}

    final index = _rates.indexWhere((r) => r.id == id);
    if (index != -1) {
      _rates[index] = _rates[index].copyWith(lastBroadcastAt: DateTime.now());
      return true;
    }
    return false;
  }
}

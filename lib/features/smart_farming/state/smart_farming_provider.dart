import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/api_client.dart';
import '../../mandi_prices/data/mandi_service.dart';
import '../../mandi_prices/domain/mandi_crop_model.dart';
import '../data/location_service.dart';
import '../data/weather_service.dart';
import '../domain/weather_model.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(apiClient: ref.watch(apiClientProvider));
});

final mandiServiceProvider = Provider<MandiService>((ref) {
  return MandiService(apiClient: ref.watch(apiClientProvider));
});

class SmartFarmingState {
  final FarmerLocation location;
  final WeatherForecast weather;
  final SatelliteRadarData? radar;
  final List<Map<String, dynamic>> broadcasts;
  final List<MandiCropItem> mandiCrops;
  final String selectedCategory;
  final String searchQuery;
  final List<MandiComparisonItem> comparisonItems;
  final String? comparingCrop;
  final bool isLoading;
  final bool isLocating;
  final bool showPerKg;

  const SmartFarmingState({
    required this.location,
    required this.weather,
    this.radar,
    this.broadcasts = const [],
    this.mandiCrops = const [],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.comparisonItems = const [],
    this.comparingCrop,
    this.isLoading = false,
    this.isLocating = false,
    this.showPerKg = false,
  });

  SmartFarmingState copyWith({
    FarmerLocation? location,
    WeatherForecast? weather,
    SatelliteRadarData? radar,
    List<Map<String, dynamic>>? broadcasts,
    List<MandiCropItem>? mandiCrops,
    String? selectedCategory,
    String? searchQuery,
    List<MandiComparisonItem>? comparisonItems,
    String? comparingCrop,
    bool? isLoading,
    bool? isLocating,
    bool? showPerKg,
  }) {
    return SmartFarmingState(
      location: location ?? this.location,
      weather: weather ?? this.weather,
      radar: radar ?? this.radar,
      broadcasts: broadcasts ?? this.broadcasts,
      mandiCrops: mandiCrops ?? this.mandiCrops,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      comparisonItems: comparisonItems ?? this.comparisonItems,
      comparingCrop: comparingCrop ?? this.comparingCrop,
      isLoading: isLoading ?? this.isLoading,
      isLocating: isLocating ?? this.isLocating,
      showPerKg: showPerKg ?? this.showPerKg,
    );
  }
}

class SmartFarmingNotifier extends StateNotifier<SmartFarmingState> {
  final LocationService locationService;
  final WeatherService weatherService;
  final MandiService mandiService;
  final ApiClient? apiClient;

  SmartFarmingNotifier({
    required this.locationService,
    required this.weatherService,
    required this.mandiService,
    this.apiClient,
  }) : super(
          SmartFarmingState(
            location: FarmerLocation.defaultLocation(),
            weather: WeatherForecast.initial(),
            radar: SatelliteRadarData.initial(),
          ),
        ) {
    init();
  }

  Future<void> init() async {
    await refreshLocationAndWeather();
    await loadMandiRates();
  }

  Future<void> refreshLocationAndWeather() async {
    state = state.copyWith(isLocating: true);
    try {
      final loc = await locationService.getCurrentFarmerLocation();
      final weather = await weatherService.getWeatherForLocation(loc);
      final radar = await weatherService.getSatelliteRadar(loc);

      List<Map<String, dynamic>> alerts = state.broadcasts;
      if (apiClient != null) {
        try {
          final resp = await apiClient!.get('/api/v1/admin/broadcasts');
          if (resp is List) {
            alerts = resp.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
          }
        } catch (_) {}
      }

      state = state.copyWith(
        location: loc,
        weather: weather,
        radar: radar,
        broadcasts: alerts,
        isLocating: false,
      );
    } catch (_) {
      state = state.copyWith(isLocating: false);
    }
  }

  Future<void> loadMandiRates() async {
    state = state.copyWith(isLoading: true);
    final rates = await mandiService.getMandiRates(
      query: state.searchQuery,
      category: state.selectedCategory,
    );
    state = state.copyWith(mandiCrops: rates, isLoading: false);
  }

  Future<void> searchCrops(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadMandiRates();
  }

  Future<void> selectCategory(String category) async {
    state = state.copyWith(selectedCategory: category);
    await loadMandiRates();
  }

  void togglePriceUnit() {
    state = state.copyWith(showPerKg: !state.showPerKg);
  }

  Future<void> compareCrop(String cropName) async {
    final comparison = await mandiService.compareCropAcrossMandis(cropName);
    state = state.copyWith(
      comparingCrop: cropName,
      comparisonItems: comparison,
    );
  }
}

final smartFarmingProvider =
    StateNotifierProvider<SmartFarmingNotifier, SmartFarmingState>((ref) {
  final locSvc = ref.watch(locationServiceProvider);
  final weatherSvc = ref.watch(weatherServiceProvider);
  final mandiSvc = ref.watch(mandiServiceProvider);
  final apiClient = ref.watch(apiClientProvider);

  return SmartFarmingNotifier(
    locationService: locSvc,
    weatherService: weatherSvc,
    mandiService: mandiSvc,
    apiClient: apiClient,
  );
});

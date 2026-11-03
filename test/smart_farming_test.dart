import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/mandi_prices/data/mandi_service.dart';
import 'package:agri_ai/features/smart_farming/data/location_service.dart';
import 'package:agri_ai/features/smart_farming/data/weather_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WeatherService weatherService;
  late MandiService mandiService;
  late LocationService locationService;

  setUp(() {
    weatherService = WeatherService();
    mandiService = MandiService();
    locationService = LocationService();
  });

  test('LocationService returns valid default farmer location on fallback', () async {
    final loc = FarmerLocation.defaultLocation();
    expect(loc.district, 'Warangal');
    expect(loc.state, 'Telangana');
    expect(loc.latitude, greaterThan(0));
    expect(loc.longitude, greaterThan(0));

    final currentLoc = await locationService.getCurrentFarmerLocation();
    expect(currentLoc.district, isNotEmpty);
  });

  test('WeatherService generates realistic forecast and spraying advisory', () async {
    final loc = FarmerLocation.defaultLocation();
    final forecast = await weatherService.getWeatherForLocation(loc);

    expect(forecast.temperature, inInclusiveRange(15.0, 48.0));
    expect(forecast.humidity, inInclusiveRange(0, 100));
    expect(forecast.rainProbability, inInclusiveRange(0, 100));
    expect(forecast.isSprayingRecommended, true);
    expect(forecast.advisoryTitle, contains('Spraying'));
    expect(forecast.hourlyForecast, isNotEmpty);
  });

  test('MandiService returns active Indian crop market rates with search and filter', () async {
    final allRates = await mandiService.getMandiRates();
    expect(allRates.length, greaterThanOrEqualTo(5));

    final searchCotton = await mandiService.getMandiRates(query: 'Cotton');
    expect(searchCotton.length, 1);
    expect(searchCotton.first.cropName, contains('Cotton'));

    final cereals = await mandiService.getMandiRates(category: 'Cereals');
    expect(cereals.every((c) => c.category == 'Cereals'), true);
  });

  test('MandiService compares crop prices across neighboring mandis and flags highest profit', () async {
    final comparison = await mandiService.compareCropAcrossMandis('Cotton');

    expect(comparison.length, 3);
    expect(comparison.any((m) => m.isHighestPrice), true);

    final highest = comparison.firstWhere((m) => m.isHighestPrice);
    expect(highest.modalPricePerQuintal, 7420);
    expect(highest.mandiName, contains('Enumamula'));
  });
}

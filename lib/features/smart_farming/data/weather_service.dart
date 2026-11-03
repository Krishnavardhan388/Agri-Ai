import '../domain/weather_model.dart';
import 'location_service.dart';

class WeatherService {
  Future<WeatherForecast> getWeatherForLocation(FarmerLocation location) async {
    // Simulated weather intelligence calculation based on season & time
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final hour = now.hour;

    double temp = 30.5;
    if (hour >= 11 && hour <= 15) {
      temp = 33.2;
    } else if (hour >= 19 || hour <= 6) {
      temp = 24.5;
    }

    const rainChance = 10;
    const windSpeed = 12.4;
    const humidity = 58;

    final isSprayingIdeal = windSpeed <= 15.0 && rainChance <= 20;

    return WeatherForecast(
      locationName: location.formattedAddress,
      temperature: temp,
      feelsLike: temp + 2.0,
      humidity: humidity,
      rainProbability: rainChance,
      windSpeedKmH: windSpeed,
      condition: 'Sunny • Clear Agricultural Skies',
      isSprayingRecommended: isSprayingIdeal,
      advisoryTitle: isSprayingIdeal
          ? 'Optimal Window for Spraying Today'
          : 'Delay Spraying Due to Rain / Wind Risk',
      advisoryDescription: isSprayingIdeal
          ? 'Clear conditions and low wind speed ($windSpeed km/h) make this the ideal window for foliar pesticide & micronutrient application.'
          : 'Higher humidity and wind indicate delayed spraying to prevent chemical drift and wash-off.',
      hourlyForecast: [
        HourlyWeather(hour: '09:00', temp: 28.0, rainChance: 5),
        HourlyWeather(hour: '12:00', temp: 32.0, rainChance: 10),
        HourlyWeather(hour: '15:00', temp: 34.0, rainChance: 10),
        HourlyWeather(hour: '18:00', temp: 30.0, rainChance: 15),
        HourlyWeather(hour: '21:00', temp: 26.0, rainChance: 5),
      ],
    );
  }
}


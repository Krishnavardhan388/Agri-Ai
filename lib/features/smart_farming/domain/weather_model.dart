class HourlyWeather {
  final String hour;
  final double temp;
  final int rainChance;

  const HourlyWeather({
    required this.hour,
    required this.temp,
    required this.rainChance,
  });
}

class WeatherForecast {
  final String locationName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final int rainProbability;
  final double windSpeedKmH;
  final String condition;
  final bool isSprayingRecommended;
  final String advisoryTitle;
  final String advisoryDescription;
  final List<HourlyWeather> hourlyForecast;

  const WeatherForecast({
    required this.locationName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.rainProbability,
    required this.windSpeedKmH,
    required this.condition,
    required this.isSprayingRecommended,
    required this.advisoryTitle,
    required this.advisoryDescription,
    required this.hourlyForecast,
  });

  factory WeatherForecast.initial() {
    return const WeatherForecast(
      locationName: 'Warangal, Telangana',
      temperature: 31.0,
      feelsLike: 33.0,
      humidity: 62,
      rainProbability: 10,
      windSpeedKmH: 12.0,
      condition: 'Sunny • Clear Sky',
      isSprayingRecommended: true,
      advisoryTitle: 'Ideal for Pesticide & Fertilizer Spraying',
      advisoryDescription:
          'Dry conditions and low wind speed (12 km/h) make this the ideal 48-hour window for foliar spray.',
      hourlyForecast: [
        HourlyWeather(hour: '09:00', temp: 28.0, rainChance: 5),
        HourlyWeather(hour: '12:00', temp: 31.0, rainChance: 10),
        HourlyWeather(hour: '15:00', temp: 33.0, rainChance: 10),
        HourlyWeather(hour: '18:00', temp: 29.0, rainChance: 15),
        HourlyWeather(hour: '21:00', temp: 26.0, rainChance: 5),
      ],
    );
  }
}

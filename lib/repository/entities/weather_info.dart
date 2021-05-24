class WeatherInfo {
  final String temperature;
  final String windSpeed;
  final String weatherSymbol;

  WeatherInfo(this.temperature, this.windSpeed, this.weatherSymbol);

  @override
  String toString() {
    return "WeatherInfo: { temperature: $temperature, windSpeed: $windSpeed, weatherSymbol: $weatherSymbol }";
  }
}

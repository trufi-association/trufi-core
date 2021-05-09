import 'package:latlong/latlong.dart';

abstract class WeatherData {
  Future<void> getCurrentWeatherAtLocation(DateTime dateTime, LatLng currentLocation);
}

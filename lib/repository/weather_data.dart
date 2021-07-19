import 'package:latlong2/latlong.dart';

abstract class WeatherData {
  Future<void> getCurrentWeatherAtLocation(DateTime dateTime, LatLng currentLocation);
}

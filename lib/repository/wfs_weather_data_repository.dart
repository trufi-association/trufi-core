import 'dart:io';

import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/repository/entities/weather_info.dart';
import 'package:trufi_core/repository/weather_data.dart';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class WFSWeatherDataRepository extends WeatherData {
  http.Client client;
  String url =
      "https://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&request=getFeature&storedquery_id=fmi::forecast::hirlam::surface::point::simple&timestep=5&parameters=temperature,WindSpeedMS,WeatherSymbol3";

  WFSWeatherDataRepository({http.Client client})
      : client = client ?? http.Client();

  @override
  Future<WeatherInfo> getCurrentWeatherAtLocation(
      DateTime dateTime, LatLng currentLocation) async {
    final DateTime now = dateTime.toUtc();
    final String currentTime = DateFormat("yyyy-MM-ddTHH:mm:ss").format(
      DateTime(now.year, now.month, now.day, now.hour),
    );
    final String newURL =
        "$url&latlon=${currentLocation.latitude},${currentLocation.longitude}&starttime=${currentTime}Z&endtime=${currentTime}Z";

    final http.Response result = await client.get(Uri.parse(newURL));

    if (result.statusCode == 200) {
      return _parseXMLToWeatherInfo(result.body);
    }

    throw HttpException(
      "Could not get the current Weather at your location ${result.statusCode}",
    );
  }

  WeatherInfo _parseXMLToWeatherInfo(String xml) {
    final document = XmlDocument.parse(xml);

    final List<String> parameterValues = document
        .findAllElements("BsWfs:ParameterValue")
        .map((e) => e.text)
        .toList();

    return WeatherInfo(
      parameterValues[0],
      parameterValues[1],
      parameterValues[2],
    );
  }
}

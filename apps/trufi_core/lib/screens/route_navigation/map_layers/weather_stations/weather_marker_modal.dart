import 'package:flutter/material.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/weather_stations/weather_feature_model.dart';

import 'package:intl/intl.dart';

class WeatherMarkerModal extends StatelessWidget {
  final WeatherFeature weatherFeature;
  final Widget icon;

  const WeatherMarkerModal({
    super.key,
    required this.weatherFeature,
    required this.icon,
  });

  String _mapRoadCondition(int? value, bool isEnglish) {
    const roadConditions = {
      10: {'en': "Dry", 'de': "Trocken"},
      15: {'en': "Humid", 'de': "Feucht"},
      20: {'en': "Wet", 'de': "Nass"},
      25: {'en': "Humid with salt", 'de': "Feucht mit Salz"},
      30: {'en': "Wet with salt", 'de': "Nass mit Salz"},
      35: {'en': "Ice", 'de': "Eis"},
      40: {'en': "Snow", 'de': "Schnee"},
      45: {'en': "Frost", 'de': "Frost / Reif"},
    };
    final lang = isEnglish ? 'en' : 'de';
    return roadConditions[value]?[lang] ??
        (isEnglish ? "Unknown" : "Unbekannt");
  }

  String _mapPrecipitationType(int? value, bool isEnglish) {
    const precipitationTypes = {
      0: {'en': "No precipitation", 'de': "kein Niederschlag"},
      60: {
        'en': "Liquid precipitation, e.g. rain",
        'de': "flüssiger Niederschlag, z.B. Regen",
      },
      70: {
        'en': "Solid precipitation, e.g. snow",
        'de': "fester Niederschlag, z.B. Schnee",
      },
      67: {'en': "Freezing rain", 'de': "Eisregen"},
      69: {'en': "Sleet", 'de': "Schneeregen"},
      90: {'en': "Hail", 'de': "Hagel"},
    };
    final lang = isEnglish ? 'en' : 'de';
    return precipitationTypes[value]?[lang] ??
        (isEnglish ? "Unknown" : "Unbekannt");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglishCode = true;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: icon,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglishCode ? 'Weather station' : 'Wetterstation',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weatherFeature.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (weatherFeature.airTemperatureC != null)
                _buildRow(
                  isEnglishCode ? 'Air Temperature' : 'Lufttemperatur',
                  "${weatherFeature.airTemperatureC} °C",
                  theme,
                ),
              if (weatherFeature.airPressureRelhPa != null)
                _buildRow(
                  isEnglishCode ? 'Air Pressure' : 'Luftdruck',
                  "${weatherFeature.airPressureRelhPa} hPa",
                  theme,
                ),
              if (weatherFeature.moisturePercentage != null)
                _buildRow(
                  isEnglishCode ? 'Humidity' : 'Luftfeuchtigkeit',
                  "${weatherFeature.moisturePercentage} %",
                  theme,
                ),
              if (weatherFeature.roadTemperatureC != null)
                _buildRow(
                  isEnglishCode ? 'Road Temperature' : 'Straßentemperatur',
                  "${weatherFeature.roadTemperatureC} °C",
                  theme,
                ),
              if (weatherFeature.precipitationType != null)
                _buildRow(
                  isEnglishCode ? 'Precipitation' : 'Niederschlag',
                  _mapPrecipitationType(
                    int.tryParse(weatherFeature.precipitationType!),
                    isEnglishCode,
                  ),
                  theme,
                ),
              if (weatherFeature.roadCondition != null)
                _buildRow(
                  isEnglishCode ? 'Road Condition' : 'Straßenzustand',
                  _mapRoadCondition(
                    int.tryParse(weatherFeature.roadCondition!),
                    isEnglishCode,
                  ),
                  theme,
                ),
              if (weatherFeature.icePercentage != null)
                _buildRow(
                  isEnglishCode ? 'Ice Percentage' : 'Eisprozent',
                  "${weatherFeature.icePercentage} %",
                  theme,
                ),
              if (weatherFeature.updatedAt != null)
                _buildRow(
                  isEnglishCode ? 'Last Update' : 'Daten von',
                  formatDateWithoutSeconds(weatherFeature.updatedAt!, "en"),
                  theme,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(1),
                fontSize: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDateWithoutSeconds(String date, String languageCode) {
    final parsedDate = DateTime.parse(date).toLocal();
    String formattedDate = DateFormat(null, languageCode).format(parsedDate);
    formattedDate = formattedDate.replaceFirst(RegExp(r':\d{2}(?=\s|$)'), '');
    if (languageCode == 'de' && !formattedDate.contains('Uhr')) {
      formattedDate += ' Uhr';
    }

    return formattedDate;
  }
}

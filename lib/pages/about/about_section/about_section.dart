import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'image_base64.dart'; // Si no usarás la imagen, puedes remover esta import.

class AboutSection extends StatelessWidget {
  static const _padding = EdgeInsets.only(top: 16.0);

  const AboutSection({
    super.key,
    required this.appName,
    required this.cityName,
    this.showLogo = false, // por si quieres mostrar/ocultar la imagen
  });

  final String appName;
  final String cityName;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyLarge;

    TextStyle linkStyle() => body?.copyWith(
          decoration: TextDecoration.underline,
          color: theme.colorScheme.primary,
        ) ??
        const TextStyle(decoration: TextDecoration.underline);

    Future<void> _open(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this service',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w700,
          ),
        ),

        // Descripción neutral
        Padding(
          padding: _padding,
          child: Text(
            '$appName is an experimental travel planning application for $cityName and nearby areas. '
            'The service may include public transport and walking options, as well as general mobility information. '
            'Coverage and data quality can vary and may be incomplete.',
            style: body,
          ),
        ),

        // (Opcional) Logo/imagen si quieres mantenerlo para “about”
        if (showLogo) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: 250,
            child: Image.memory(base64Decode(imageAboutSection)),
          ),
        ],


        // Fuentes de datos (neutral, evita comprometer a terceros)
        Padding(
          padding: _padding,
          child: Text(
            'Data sources',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: _padding,
          child: RichText(
            text: TextSpan(
              style: body,
              children: [
                const TextSpan(text: 'Base map and POI data: '),
                TextSpan(
                  text: '© OpenStreetMap contributors',
                  style: linkStyle(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _open('https://www.openstreetmap.org/copyright'),
                ),
                const TextSpan(
                  text:
                      '. Public transport datasets may originate from local operators or public open-data portals where available.',
                ),
              ],
            ),
          ),
        ),

        // Licencias & créditos (sin listar licencias específicas para no equivocarnos)
        Padding(
          padding: _padding,
          child: Text(
            'Licenses & credits',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: _padding,
          child: RichText(
            text: TextSpan(
              style: body,
              children: [
                 TextSpan(
                  text:
                      '$appName uses open-source software and data. Please review the license files and notices in the application and linked project pages. ',
                ),
                TextSpan(
                  text: 'Open-source notices',
                  style: linkStyle(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _open('https://opensource.org/licenses'),
                ),
              ],
            ),
          ),
        ),

        // Disclaimer fuerte
        Padding(
          padding: _padding,
          child: Text(
            'All information is provided without guarantee. Availability, accuracy and timeliness of routes, schedules and other data may vary.',
            style: body,
          ),
        ),
      ],
    );
  } 
}
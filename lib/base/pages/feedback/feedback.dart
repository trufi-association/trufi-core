import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_core/base/pages/feedback/translations/feedback_localizations.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';

class FeedbackPage extends StatelessWidget {
  static const String route = "/Feedback";
  final String email;
  final Widget Function(BuildContext) drawerBuilder;

  const FeedbackPage({
    super.key,
    required this.drawerBuilder,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final localizationF = FeedbackLocalization.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text(localizationF.menuFeedback)]),
      ),
      drawer: drawerBuilder(context),
      body: Scrollbar(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          children: <Widget>[
            Text(
              localizationF.feedbackTitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                localizationF.feedbackContent,
                style: theme.textTheme.bodyMedium,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cityName =
              (await CitySelectionManager().getCityInstance)?.getText;
          String version = await PackageInfoPlatform.version();
          final subject = Uri.encodeComponent(
              'Comentario Rutómetro (v$version) - $cityName');

          final uri = Uri.parse('mailto:$email?subject=$subject');

          if (!await launchUrl(uri)) {
            throw 'No se pudo abrir el cliente de correo.';
          }
        },
        heroTag: null,
        child: const Icon(Icons.feedback),
      ),
    );
  }
}

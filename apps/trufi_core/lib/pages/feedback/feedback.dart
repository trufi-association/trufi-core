import 'package:flutter/material.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatelessWidget {
  static const String route = "feedback";

  final String urlFeedback;

  const FeedbackPage({super.key, required this.urlFeedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(localization.translate(LocalizationKey.feedbackMenu)),
          ],
        ),
      ),
      body: Scrollbar(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          children: <Widget>[
            Text(
              localization.translate(LocalizationKey.feedbackTitle),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 20),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                localization.translate(LocalizationKey.feedbackContent),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          launchUrl(Uri.parse(urlFeedback));
        },
        heroTag: null,
        child: const Icon(Icons.feedback),
      ),
    );
  }
}

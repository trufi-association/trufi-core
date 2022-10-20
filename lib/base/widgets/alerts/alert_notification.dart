import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/base_build_alert.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertNotification extends StatefulWidget {
  static Future<void> showNotification({
    required BuildContext context,
    required String title,
    required Future<void> Function() makeDoNotShowAgain,
    required String? description,
    String? uri,
  }) async {
    await showTrufiDialog<void>(
      context: context,
      onWillPop: false,
      builder: (_) {
        return AlertNotification(
          title: title,
          makeDoNotShowAgain: makeDoNotShowAgain,
          description: description,
          uri: uri,
        );
      },
    );
  }

  final String title;
  final Future<void> Function() makeDoNotShowAgain;
  final String? description;
  final String? uri;

  const AlertNotification({
    super.key,
    required this.title,
    required this.makeDoNotShowAgain,
    this.description,
    this.uri,
  });

  @override
  State<AlertNotification> createState() => _AlertNotificationState();
}

class _AlertNotificationState extends State<AlertNotification> {
  bool check = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 15),
          iconPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.notifications_active, size: 60),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.description != null && widget.description != '')
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: _DescriptionDecoder(description: widget.description!),
                )
              else
                const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    localization.notShowAgain,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Checkbox(
                    value: check,
                    onChanged: (data) {
                      setState(() {
                        check = data ?? false;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 0),
            ],
          ),
          actions: [
            CancelButton(
              onPressed: () async {
                if (check) {
                  await widget.makeDoNotShowAgain();
                }
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
            OKButton(
              onPressed: () async {
                if (check) {
                  await widget.makeDoNotShowAgain();
                }
                if (widget.uri != null && await canLaunch(widget.uri!)) {
                  launch(widget.uri!);
                }
                if (!mounted) return;
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _DescriptionDecoder extends StatelessWidget {
  final String description;
  const _DescriptionDecoder({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regexUriText = RegExp(r'\[(.*?)\)');
    final matchesUriText = regexUriText.allMatches(description);
    final textsSimples = (description).split(regexUriText);
    int index = 0;
    return RichText(
      text: TextSpan(
        children: [
          ...matchesUriText.map((match) {
            RegExp exp = RegExp(r'(?<=\[)(.*?)(?=\])');
            RegExp exp2 = RegExp(r'(?<=\()(.*?)(?=\))');
            final textSimple = textsSimples[index];
            index++;
            final uriText = exp.firstMatch(match[0]!)?[0]!;
            final uri = exp2.firstMatch(match[0]!)![0]!;

            return TextSpan(children: [
              TextSpan(
                text: textSimple,
                style: theme.textTheme.bodyText2?.copyWith(fontSize: 14),
              ),
              TextSpan(
                text: uriText,
                style: theme.textTheme.bodyText2?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch(uri);
                  },
              ),
              if (index == matchesUriText.length)
                TextSpan(
                  text: textsSimples[index],
                  style: theme.textTheme.bodyText2?.copyWith(fontSize: 14),
                ),
            ]);
          }).toList(),
        ],
      ),
    );
  }
}

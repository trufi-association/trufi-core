import 'package:cached_network_image/cached_network_image.dart';
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
    String? imageUrl,
    String? bttnText,
    String? bttnUrl,
  }) async {
    await showTrufiDialog<void>(
      context: context,
      onWillPop: false,
      builder: (_) {
        return AlertNotification(
          title: title,
          makeDoNotShowAgain: makeDoNotShowAgain,
          description: description,
          imageUrl: imageUrl,
          bttnText: bttnText,
          bttnUrl: bttnUrl,
        );
      },
    );
  }

  final String title;
  final Future<void> Function() makeDoNotShowAgain;
  final String? description;
  final String? imageUrl;
  final String? bttnText;
  final String? bttnUrl;

  const AlertNotification({
    super.key,
    required this.title,
    required this.makeDoNotShowAgain,
    this.description,
    this.imageUrl,
    this.bttnText,
    this.bttnUrl,
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: AlertDialog(
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
            iconPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl!,
                        progressIndicatorBuilder: (_, __, ___) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const SizedBox(height: 0),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (widget.description != null && widget.description != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: DescriptionDecoder(description: widget.description!),
                  ),
                if (widget.bttnText != null && widget.bttnUrl != null)
                  ElevatedButton(
                    onPressed: () {
                      launchUrl(Uri.parse(widget.bttnUrl!));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(50, 30),
                    ),
                    child: Text(
                      widget.bttnText!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 10),
                const Divider(height: 0),
              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  setState(() {
                    check = !check;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        localization.notShowAgain,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Checkbox(
                          value: check,
                          onChanged: (data) {
                            setState(() {
                              check = !check;
                            });
                          },
                          activeColor: theme.colorScheme.secondary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              OKButton(
                onPressed: () async {
                  if (check) {
                    await widget.makeDoNotShowAgain();
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DescriptionDecoder extends StatelessWidget {
  final String description;
  const DescriptionDecoder({
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
                    launchUrl(Uri.parse(uri));
                  },
              ),
              if (index == matchesUriText.length)
                TextSpan(
                  text: textsSimples[index],
                  style: theme.textTheme.bodyText2?.copyWith(fontSize: 14),
                ),
            ]);
          }).toList(),
          if (matchesUriText.isEmpty)
            TextSpan(
              text: description,
              style: theme.textTheme.bodyText2?.copyWith(fontSize: 14),
            ),
        ],
      ),
    );
  }
}

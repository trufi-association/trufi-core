import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/widgets/basic_widgets/trufi_expansion_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_core/base/pages/about/translations/about_localizations.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class AboutPage extends StatelessWidget {
  static const String route = "/About";

  final String appName;
  final String cityName;
  final String countryName;
  final String emailContact;
  final Widget Function(BuildContext) drawerBuilder;

  const AboutPage({
    super.key,
    required this.appName,
    required this.cityName,
    required this.countryName,
    required this.emailContact,
    required this.drawerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final localizationA = AboutLocalization.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(localizationA.menuAbout),
          ],
        ),
      ),
      drawer: drawerBuilder(context),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                height: 300,
                child: Image.asset(
                  'assets/images/trufi-logo.png',
                  package: 'trufi_core',
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.07),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 40),
              children: [
                FutureBuilder(
                  future: PackageInfoPlatform.version(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<String> snapshot,
                  ) {
                    if (snapshot.hasError ||
                        snapshot.connectionState != ConnectionState.done) {
                      return const Text("");
                    }
                    return Text(
                      localizationA.version(snapshot.data ?? ''),
                      style: const TextStyle(fontWeight: FontWeight.w100),
                      textAlign: TextAlign.right,
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TrufiExpansionTile(
                  title: appName,
                  typeTitle: ExpansionTileTitleType.secondary,
                  body: null,
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    localizationA.tagline("$cityName, $countryName"),
                    style: theme.textTheme.titleSmall?.copyWith(),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    localizationA.aboutContent(appName, cityName),
                  ),
                ),
                const SizedBox(height: 24),
                TrufiExpansionTile(
                  title: localizationA.aboutCollapseTitle,
                  typeTitle: ExpansionTileTitleType.secondary,
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text(
                          '${localizationA.aboutCollapseContent}\n',
                          style: TrufiExpansionTile.styleTextContent,
                        ),
                        Row(
                          children: [
                            InkWell(
                              child: Text(
                                '${localizationA.trufiWebsite}\n',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                // ignore: deprecated_member_use
                                launch(
                                    'https://www.trufi-association.org/?utm_source=$cityName-$countryName&utm_medium=${localizationA.localeName}&utm_campaign=in-app-referral&utm_content=trufi-association-website');
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              child: Text(
                                '${localizationA.volunteerTrufi}\n',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                // ignore: deprecated_member_use
                                launch(
                                    'https://www.trufi-association.org/volunteering/?utm_source=$cityName-$countryName&utm_medium=${localizationA.localeName}&utm_campaign=in-app-referral&utm_content=volunteer-for-trufi');
                              },
                            ),
                          ],
                        ),
                        Text(
                          '${localizationA.aboutCollapseContentFoot}\n',
                          style: TrufiExpansionTile.styleTextContent,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    ElevatedButton(
                      child: Text(
                        localizationA.aboutLicenses,
                      ),
                      onPressed: () {
                        return customShowLicensePage(
                          context: context,
                          applicationName: appName,
                          applicationLegalese: cityName,
                          applicationIcon: Container(
                            padding: const EdgeInsets.all(20),
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    'assets/images/trufi-logo.png',
                                    package: 'trufi_core',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const SelectableText('EMAIL'),
                InkWell(
                  child: Text(
                    emailContact,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () {
                    final url = "mailto:$emailContact?subject=Contact";
                    // ignore: deprecated_member_use
                    launch(url);
                  },
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    text: localizationA.aboutOpenSource.split("GitHub")[0],
                    children: [
                      TextSpan(
                        text: 'Github',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // ignore: deprecated_member_use
                            launch(
                              'https://github.com/trufi-association/trufi-core.git',
                            );
                          },
                      ),
                      TextSpan(
                        text: localizationA.aboutOpenSource.split("GitHub")[1],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void customShowLicensePage({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    Navigator.of(context, rootNavigator: useRootNavigator)
        .push(MaterialPageRoute<void>(
      builder: (BuildContext context) => BaseTrufiPage(
        child: LicensePage(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
        ),
      ),
    ));
  }
}

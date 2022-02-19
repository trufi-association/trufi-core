import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_core/base/pages/about/translations/about_localizations.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class AboutPage extends StatelessWidget {
  static const String route = "/About";

  final String appName;
  final String cityName;
  final Widget Function(BuildContext) drawerBuilder;

  const AboutPage({
    Key? key,
    required this.appName,
    required this.cityName,
    required this.drawerBuilder,
  }) : super(key: key);

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
                Text(
                  appName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(cityName),
                const SizedBox(height: 16.0),
                Text(
                  localizationA.tagline(cityName),
                  style: theme.textTheme.subtitle2?.copyWith(),
                ),
                const SizedBox(height: 16.0),
                Text(
                  localizationA.aboutContent,
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: ExpansionTile(
                      title: Text(
                        localizationA.aboutCollapseTitle,
                        style: theme.textTheme.bodyText2?.copyWith(height: 1.5),
                      ),
                      children: [
                        Text(
                          localizationA.aboutCollapseContent,
                          style:
                              theme.textTheme.bodyText2?.copyWith(height: 1.5),
                        )
                      ],
                      backgroundColor:
                          theme.colorScheme.surface.withOpacity(0.8),
                      collapsedBackgroundColor:
                          theme.colorScheme.surface.withOpacity(0.8),
                      collapsedIconColor: theme.iconTheme.color,
                      iconColor: theme.iconTheme.color,
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
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
                InkWell(
                  child: Text(
                    localizationA.aboutOpenSource,
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  onTap: () {
                    launch(
                      'https://github.com/trufi-association/trufi-core.git',
                    );
                  },
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

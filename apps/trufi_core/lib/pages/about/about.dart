import 'package:flutter/material.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/pages/about/about_section/about_section.dart';
import 'package:trufi_core/utils/packge_info_platform.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const String route = "about";

  const AboutPage({
    super.key,
    required this.appName,
    required this.cityName,
    required this.urlRepository,
  });

  final String appName;
  final String cityName;
  final String urlRepository;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final localization = AppLocalization.of(context);
    return AppBar(
      title: Row(
        children: [Text(localization.translate(LocalizationKey.aboutUsMenu))],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);
    return Scrollbar(
      child: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  cityName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: AboutSection(appName: appName, cityName: cityName),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
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
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        useRootNavigator: true,
                      );
                    },
                    child: Text(
                      localization.translate(LocalizationKey.aboutUsLicenses),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: PackageInfoPlatform.version(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasError ||
                        snapshot.connectionState != ConnectionState.done) {
                      return const Text("");
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          localization.translateWithParams(
                            '${LocalizationKey.aboutUsVersion.key}: ${snapshot.data ?? ''}',
                          ),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: InkWell(
                    onTap: () {
                      launchUrl(Uri.parse(urlRepository));
                    },
                    child: Text(
                      localization.translate(LocalizationKey.aboutUsOpenSource),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    Navigator.of(context, rootNavigator: useRootNavigator).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LicensePage(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/trufi_drawer.dart';

class AboutPage extends StatefulWidget {
  static const String route = "/about";

  const AboutPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: const TrufiDrawer(AboutPage.route),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return AppBar(title: Text(localization.menuAbout));
  }

  Widget _buildBody(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final theme = Theme.of(context);
    final TextStyle linkStyle = theme.textTheme.bodyText1.copyWith(
      color: theme.accentColor,
    );

    final config = context.read<ConfigurationCubit>().state;
    final currentCity = config.appCity;
    final customTranslations = config.customTranslations;
    final currentLocale = Localizations.localeOf(context);

    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                customTranslations.get(customTranslations.title, currentLocale,
                    localization.title),
                style: theme.textTheme.headline6.copyWith(
                  color: theme.textTheme.bodyText1.color,
                ),
              ),
              FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<PackageInfo> snapshot,
                ) {
                  if (snapshot.hasError ||
                      snapshot.connectionState != ConnectionState.done) {
                    return const Text("");
                  }
                  return Text(
                    localization.version(snapshot.data.version),
                    style: theme.textTheme.bodyText1,
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  customTranslations.get(customTranslations.tagline,
                      currentLocale, localization.tagline(currentCity)),
                  style: theme.textTheme.subtitle1.copyWith(
                    color: theme.textTheme.bodyText1.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  customTranslations.get(customTranslations.aboutContent,
                      currentLocale, localization.aboutContent),
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    return showLicensePage(
                      context: context,
                      applicationName: customTranslations.get(
                        customTranslations.title,
                        currentLocale,
                        localization.title,
                      ),
                    );
                  },
                  child: Text(localization.aboutLicenses),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () {
                    launch('https://github.com/trufi-association/trufi-app');
                  },
                  child: Text(
                    localization.aboutOpenSource,
                    style: linkStyle,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/widgets/trufi_drawer.dart';

import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  static const String route = "/about";

  @override
  State<StatefulWidget> createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: TrufiDrawer(AboutPage.route),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return AppBar(
      title: Text(localizations.menuAbout()),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle linkStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);

    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                child: Text(
                  localizations.title(),
                  style: theme.textTheme.title.copyWith(
                    color: theme.textTheme.body2.color,
                  ),
                ),
              ),
              Container(
                child: new FutureBuilder(
                  future: packageInfo,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<PackageInfo> snapshot,
                  ) {
                    if (snapshot.hasError ||
                        snapshot.connectionState != ConnectionState.done) {
                      return Text("");
                    }
                    return Text(
                      localizations.version(snapshot.data.version),
                      style: theme.textTheme.body2,
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localizations.tagline(),
                  style: theme.textTheme.subhead.copyWith(
                    color: theme.textTheme.body2.color,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localizations.aboutContent(),
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: RaisedButton(
                  child: Text(localizations.aboutLicenses()),
                  onPressed: () {
                    return showLicensePage(
                      context: context,
                      applicationName: localizations.title(),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: InkWell(
                  child: new Text(
                    localizations.aboutOpenSource(),
                    style: linkStyle,
                  ),
                  onTap: () => { launch('https://github.com/trufi-association/trufi-app') }
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

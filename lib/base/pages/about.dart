import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class AboutPage extends StatelessWidget {
  static const String route = "/About";
  final Widget Function(BuildContext) drawerBuilder;

  const AboutPage({
    Key? key,
    required this.drawerBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localization.menuAbout)),
      drawer: drawerBuilder(context),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text("title"),
                  const Text("currentCity"),
                  Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: const Text("aboutContent"),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        return showLicensePage(
                          context: context,
                          applicationName: "title",
                        );
                      },
                      child: const Text("aboutLicenses"),
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
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            // localization.version(snapshot.data.version),
                            snapshot.data?.version ?? "none",
                          ),
                        ],
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: InkWell(
                      onTap: () {
                        // TODO: launch('https://github.com/trufi-association/trufi-app');
                      },
                      child: const Text("aboutOpenSource"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/drawer/menu/menu_item.dart';
import 'package:share_plus/share_plus.dart';

class TrufiDrawer extends StatelessWidget {
  const TrufiDrawer(
    this.currentRoute, {
    Key? key,
    required this.appName,
    required this.cityName,
    required this.countryName,
    this.backgroundImageBuilder,
    required this.urlShareApp,
    required this.menuItems,
  }) : super(key: key);

  final String appName;
  final String cityName;
  final String countryName;
  final String urlShareApp;
  final String currentRoute;
  final List<List<TrufiMenuItem>> menuItems;
  final WidgetBuilder? backgroundImageBuilder;

  @override
  Widget build(BuildContext context) {
    final inAppReview = InAppReview.instance;
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (backgroundImageBuilder != null)
                  backgroundImageBuilder!(context)
                else
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black12,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appName,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '$cityName - $countryName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              FutureBuilder<bool>(
                                future:  inAppReview.isAvailable(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      (snapshot.data ?? false)) {
                                    return IconButton(
                                      onPressed: () async {
                                        await inAppReview.requestReview();
                                      },
                                      icon: const Icon(
                                        Icons.star_rate,
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  final localization =
                                      TrufiBaseLocalization.of(context);

                                  Share.share(
                                    localization.shareAppText(
                                      urlShareApp,
                                      appName,
                                      cityName,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.share,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ...menuItems.fold<List<Widget>>(
                  [],
                  (previousValue, element) => [
                    ...previousValue,
                    if (previousValue.isNotEmpty) const Divider(),
                    ...element.map(
                      (element) => element.buildItem(
                        context,
                        isSelected: currentRoute == element.id,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

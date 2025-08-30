import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/city_selector/city_selector_dialog.dart';

import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/drawer/menu/trufi_menu_item.dart';
import 'package:share_plus/share_plus.dart';

class TrufiDrawer extends StatelessWidget {
  const TrufiDrawer(
    this.currentRoute, {
    super.key,
    required this.appName,
    required this.cityName,
    required this.countryName,
    this.backgroundImageBuilder,
    required this.urlShareApp,
    required this.menuItems,
    this.refreshPage,
  });

  final String appName;
  final String cityName;
  final String countryName;
  final String urlShareApp;
  final String currentRoute;
  final List<List<TrufiMenuItem>> menuItems;
  final WidgetBuilder? backgroundImageBuilder;
  final void Function()? refreshPage;

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
                          InkWell(
                            onTap: () async {
                              final city = await CitySelectorDialog.showModal(
                                context,
                                hideCloseButton: false,
                                barrierDismissible: false,
                              );
                              await CitySelectionManager().assignCity(city!);
                              await context.read<RoutePlannerCubit>().reset();
                              Navigator.of(context).pop();
                              Routemaster.of(context)
                                  .replace('${HomePage.route}?refresh=true');
                            },
                            child: Padding(
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
                                  Row(
                                    children: [
                                      Text(
                                        '${CitySelectionManager().currentCity.getText} - $countryName',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down_sharp,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              FutureBuilder<bool>(
                                future: inAppReview.isAvailable(),
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

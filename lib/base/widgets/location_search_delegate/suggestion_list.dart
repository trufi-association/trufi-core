import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/icons.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';
import 'package:trufi_core/base/widgets/location_search_delegate/favorite_button.dart';

class SuggestionList extends StatelessWidget {
  final String query;
  final bool isOrigin;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiLocation> onSelectedMap;
  final ValueChanged<TrufiStreet> onStreetTapped;
  final SelectLocationData selectPositionOnPage;
  const SuggestionList({
    super.key,
    required this.query,
    required this.isOrigin,
    required this.onSelected,
    required this.onSelectedMap,
    required this.onStreetTapped,
    required this.selectPositionOnPage,
  });

  @override
  Widget build(BuildContext context) {
    final searchLocationsCubit = context.watch<SearchLocationsCubit>();
    final localizationSP = SavedPlacesLocalization.of(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: CustomScrollView(
          slivers: [
            _BuildYourLocation(onSelected),
            _BuildChooseOnMap(
              onSelectedMap: onSelectedMap,
              isOrigin: isOrigin,
              selectPositionOnPage: selectPositionOnPage,
            ),
            if (query.isEmpty)
              _BuildYourPlaces(
                title: localizationSP.menuYourPlaces,
                places: [
                  ...searchLocationsCubit.state.myDefaultPlaces
                      .where((element) => element.isLatLngDefined)
                      .toList(),
                  ...searchLocationsCubit.state.myPlaces
                ],
                onSelected: onSelected,
              ),
            if (query.isEmpty)
              _BuildObjectList(
                title: localizationSP.searchTitleFavorites,
                iconData: Icons.place,
                places: searchLocationsCubit.state.favoritePlaces,
                onSelected: onSelected,
                onStreetTapped: onStreetTapped,
              ),
            if (query.isEmpty)
              _BuildObjectList(
                title: localizationSP.searchTitleRecent,
                iconData: Icons.history,
                places: searchLocationsCubit.getHistoryList(),
                onSelected: onSelected,
                onStreetTapped: onStreetTapped,
              ),
            _BuildFutureBuilder(
              title: localizationSP.searchTitleResults,
              query: query,
              data: searchLocationsCubit.state.searchResult,
              isLoading: searchLocationsCubit.state.isLoading,
              iconData: Icons.place,
              isVisibleWhenEmpty: true,
              onSelected: onSelected,
              onStreetTapped: onStreetTapped,
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildFutureBuilder extends StatelessWidget {
  final String title;
  final String query;
  final bool isLoading;
  final List<TrufiPlace> data;
  final IconData iconData;
  final bool isVisibleWhenEmpty;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiStreet> onStreetTapped;

  const _BuildFutureBuilder({
    required this.title,
    required this.query,
    required this.isLoading,
    required this.data,
    required this.iconData,
    required this.onSelected,
    required this.onStreetTapped,
    this.isVisibleWhenEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    if (query.isEmpty) {
      return const SliverToBoxAdapter();
    } else if (isLoading) {
      return SliverToBoxAdapter(
        child: LinearProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
        ),
      );
    } else if (data.isNotEmpty) {
      return _BuildObjectList(
        title: title,
        iconData: iconData,
        places: context.read<SearchLocationsCubit>().sortedByFavorites(data),
        onSelected: onSelected,
        onStreetTapped: onStreetTapped,
      );
    } else if (!isLoading && data.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            _BuildTitle(title: title),
            _BuildErrorItem(title: localization.commonNoResults),
          ],
        ),
      );
    }
    return const SliverToBoxAdapter();
  }
}

class _BuildChooseOnMap extends StatelessWidget {
  final ValueChanged<TrufiLocation> onSelectedMap;
  final SelectLocationData selectPositionOnPage;
  final bool isOrigin;
  const _BuildChooseOnMap({
    required this.onSelectedMap,
    required this.selectPositionOnPage,
    required this.isOrigin,
  });

  @override
  Widget build(BuildContext context) {
    final localizationSP = SavedPlacesLocalization.of(context);
    return SliverToBoxAdapter(
      child: BuildItem(
        onTap: () async {
          final chooseLocationDetail = await selectPositionOnPage(
            context,
            isOrigin: isOrigin,
          );

          if (chooseLocationDetail != null) {
            onSelectedMap(
              TrufiLocation.fromChooseLocationDetail(chooseLocationDetail),
            );
          }
        },
        iconData: const Icon(Icons.place),
        title: localizationSP.chooseOnMap,
      ),
    );
  }
}

class _BuildYourPlaces extends StatelessWidget {
  final String title;
  final ValueChanged<TrufiLocation> onSelected;
  final List<TrufiLocation> places;

  const _BuildYourPlaces({
    required this.title,
    required this.onSelected,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationSP = SavedPlacesLocalization.of(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final TrufiLocation location = places[index];
          return Column(
            children: [
              if (index == 0) _BuildTitle(title: title),
              BuildItem(
                onTap: () {
                  onSelected(location);
                },
                iconData:
                    typeToIconData(location.type, color: theme.iconTheme.color),
                title: location.displayName(localizationSP),
                subtitle: location.address,
              ),
            ],
          );
        },
        childCount: places.length,
      ),
    );
  }
}

class _BuildObjectList extends StatelessWidget {
  final String title;
  final IconData iconData;
  final List<TrufiPlace> places;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiStreet> onStreetTapped;

  const _BuildObjectList({
    required this.title,
    required this.iconData,
    required this.places,
    required this.onSelected,
    required this.onStreetTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationSP = SavedPlacesLocalization.of(context);
    final searchLocationsCubit = context.watch<SearchLocationsCubit>();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return _BuildTitle(title: title);
          }
          final object = places[index - 1];
          if (object is TrufiLocation) {
            return BuildItem(
              onTap: () {
                searchLocationsCubit.insertHistoryPlace(object);
                onSelected(object);
              },
              iconData:
                  typeToIconData(object.type, color: theme.iconTheme.color),
              title: object.displayName(localizationSP),
              subtitle: object.address,
              trailing: FavoriteButton(
                location: object,
              ),
            );
          } else if (object is TrufiStreet) {
            return BuildItem(
              onTap: () {
                onStreetTapped(object);
              },
              iconData: const Icon(Icons.label),
              title: object.displayName(localizationSP),
              trailing: const Icon(Icons.keyboard_arrow_right),
            );
          }
          return Container();
        },
        childCount: places.isNotEmpty ? places.length + 1 : 0,
      ),
    );
  }
}

class _BuildYourLocation extends StatefulWidget {
  final ValueChanged<TrufiLocation> onMapTapped;

  const _BuildYourLocation(this.onMapTapped);

  @override
  State<_BuildYourLocation> createState() => _BuildYourLocationState();
}

class _BuildYourLocationState extends State<_BuildYourLocation> {
  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    return SliverToBoxAdapter(
      child: BuildItem(
        onTap: () => _handleOnYourLocationTapped(context),
        iconData: const Icon(Icons.gps_fixed),
        title: localization.commonYourLocation,
      ),
    );
  }

  Future<void> _handleOnYourLocationTapped(BuildContext context) async {
    final localization = TrufiBaseLocalization.of(context);
    final locationProvider = GPSLocationProvider();
    final currentLocation = locationProvider.myLocation;
    if (currentLocation != null) {
      final TrufiLocation value = TrufiLocation(
        description: localization.commonYourLocation,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      widget.onMapTapped(value);
    } else {
      await locationProvider.startLocation(context, mounted);
    }
  }
}

class _BuildErrorList extends StatelessWidget {
  final String title;
  final String error;

  const _BuildErrorList({
    super.key,
    required this.title,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _BuildTitle(title: title),
          _BuildErrorItem(title: error),
        ],
      ),
    );
  }
}

class _BuildTitle extends StatelessWidget {
  final String title;

  const _BuildTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Row(
        children: <Widget>[
          Container(padding: const EdgeInsets.all(4.0)),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }
}

class _BuildErrorItem extends StatelessWidget {
  final String title;

  const _BuildErrorItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BuildItem(
      onTap: () {},
      iconData: const Icon(Icons.error),
      title: title,
    );
  }
}

class BuildItem extends StatelessWidget {
  final void Function() onTap;
  final Widget iconData;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const BuildItem({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 1,
        ),
        child: Row(
          children: <Widget>[
            iconData,
            const SizedBox(width: 10.0, height: 48.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style:
                          TextStyle(fontSize: 13, color: hintTextColor(theme)),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/search_location/location_form_field.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/utils/util_icons/icons.dart';

import '../blocs/gps_location/location_provider_cubit.dart';
import '../blocs/location_search_bloc.dart';
import '../pages/choose_location.dart';
import '../trufi_models.dart';
import '../widgets/alerts.dart';
import '../widgets/favorite_button.dart';

class LocationSearchDelegate extends SearchDelegate<TrufiLocation> {
  LocationSearchDelegate();

  TrufiLocation _result;

  @override
  ThemeData appBarTheme(BuildContext context) =>
      context.read<ThemeCubit>().state.searchTheme;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
      ),
      tooltip: "Back",
      onPressed: () {
        if (_result != null) {
          _result = null;
          showSuggestions(context);
        } else {
          close(context, null);
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SuggestionList(
      query: query,
      onSelected: (TrufiLocation suggestion) {
        _result = suggestion;
        close(context, suggestion);
      },
      onSelectedMap: (TrufiLocation suggestion) {
        _result = suggestion;
        showResults(context);
      },
      onStreetTapped: (TrufiStreet street) {
        _result = street.location;
        close(context, street.location);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (_result != null) {
      if (_result is TrufiStreet) {
        return _buildStreetResults(context, _result as TrufiStreet);
      } else {
        Future.delayed(Duration.zero, () {
          close(context, _result);
        });
      }
    }
    return buildSuggestions(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  Widget _buildStreetResults(BuildContext context, TrufiStreet street) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(slivers: [
          const SliverPadding(padding: EdgeInsets.all(4.0)),
          _buildStreetResultList(context, street),
          const SliverPadding(padding: EdgeInsets.all(4.0))
        ]),
      ),
    );
  }

  Widget _buildStreetResultList(
    BuildContext context,
    TrufiStreet street,
  ) {
    // final favoriteLocationsCubit = context.read<FavoriteLocationsCubit>();

    final searchLocationsCubit = context.watch<SearchLocationsCubit>();
    final config = context.read<ConfigurationCubit>().state;
    final localization = TrufiLocalization.of(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Center
          if (index == 0) {
            return _BuildItem(
              () {
                searchLocationsCubit.insertHistoryPlace(street.location);
                close(context, street.location);
              },
              Icons.label,
              street.displayName(config.abbreviations),
              trailing: FavoriteButton(
                location: street.location,
                color: appBarTheme(context).primaryIconTheme.color,
              ),
            );
          }
          // Junctions
          final junction = street.junctions[index - 1];
          return _BuildItem(
            () {
              searchLocationsCubit.insertHistoryPlace(
                junction.location(localization),
              );
              close(
                context,
                junction.location(localization),
              );
            },
            Icons.label_outline,
            localization.instructionJunction(
              "...",
              junction.street2.displayName,
            ),
            trailing: FavoriteButton(
              location: junction.location(localization),
              color: appBarTheme(context).primaryIconTheme.color,
            ),
          );
        },
        childCount: street.junctions.length + 1,
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    this.query,
    this.onSelected,
    this.onSelectedMap,
    this.onStreetTapped,
  });

  final String query;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiLocation> onSelectedMap;
  final ValueChanged<TrufiStreet> onStreetTapped;

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);

    final searchLocationsCubit = context.watch<SearchLocationsCubit>();
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(slivers: [
          const SliverPadding(padding: EdgeInsets.all(4.0)),
          _BuildYourLocation(onSelected),
          _BuildChooseOnMap(onSelectedMap),
          if (query.isEmpty)
            _BuildYourPlaces(
                onSelected: onSelected,
                locations: searchLocationsCubit.state.myDefaultPlaces
                    .where((element) => element.isLatLngDefined)
                    .toList()),
          if (query.isEmpty)
            _BuildYourPlaces(
                onSelected: onSelected,
                locations: searchLocationsCubit.state.myPlaces),
          if (query.isEmpty)
            _BuildObjectList(
              localization.searchTitleFavorites,
              Icons.place,
              searchLocationsCubit.state.favoritePlaces,
              onSelected,
              onStreetTapped,
            ),
          if (query.isEmpty)
            _BuildObjectList(
              localization.searchTitleRecent,
              Icons.history,
              searchLocationsCubit.getHistoryList(),
              onSelected,
              onStreetTapped,
            ),
          if (query.isNotEmpty)
            _BuildFutureBuilder(
              title: localization.searchTitleResults,
              future: searchLocationsCubit.fetchLocations(
                LocationSearchBloc.of(context),
                query,
                correlationId:
                    context.read<PreferencesCubit>().state.correlationId,
              ),
              iconData: Icons.place,
              isVisibleWhenEmpty: true,
              onSelected: onSelected,
              onStreetTapped: onStreetTapped,
            ),
          const SliverPadding(padding: EdgeInsets.all(4.0))
        ]),
      ),
    );
  }
}

class _BuildFutureBuilder extends StatelessWidget {
  final String title;
  final Future<List<TrufiPlace>> future;
  final IconData iconData;
  final bool isVisibleWhenEmpty;

  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiStreet> onStreetTapped;

  const _BuildFutureBuilder({
    @required this.title,
    @required this.future,
    @required this.iconData,
    this.isVisibleWhenEmpty = false,
    this.onSelected,
    this.onStreetTapped,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      initialData: null,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<TrufiPlace>> snapshot,
      ) {
        final localization = TrufiLocalization.of(context);
        // Error
        if (snapshot.hasError) {
          String error = localization.commonUnknownError;
          if (snapshot.error is FetchOfflineRequestException) {
            error = "Offline mode is not implemented yet";
          } else if (snapshot.error is FetchOfflineResponseException) {
            error = "Offline mode is not implemented yet";
          } else if (snapshot.error is FetchOnlineRequestException) {
            error = localization.commonNoInternet;
          } else if (snapshot.error is FetchOnlineResponseException) {
            error = localization.commonFailLoading;
          }
          return _BuildErrorList(title: title, error: error);
        }
        // Loading
        if (snapshot.data == null) {
          return SliverToBoxAdapter(
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
            ),
          );
        }
        // No results
        final int count =
            snapshot.data.isNotEmpty ? snapshot.data.length + 1 : 0;
        if (count == 0 && isVisibleWhenEmpty) {
          return SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _BuildTitle(title: title),
                _BuildErrorItem(title: localization.searchItemNoResults),
              ],
            ),
          );
        }
        // Items
        return _BuildObjectList(
          title,
          iconData,
          context.read<SearchLocationsCubit>().sortedByFavorites(snapshot.data),
          onSelected,
          onStreetTapped,
        );
      },
    );
  }
}

class _BuildYourLocation extends StatelessWidget {
  final ValueChanged<TrufiLocation> onMapTapped;

  const _BuildYourLocation(this.onMapTapped);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return SliverToBoxAdapter(
      child: _BuildItem(
        () => _handleOnYourLocationTapped(context),
        Icons.gps_fixed,
        localization.searchItemYourLocation,
      ),
    );
  }

  Future<void> _handleOnYourLocationTapped(BuildContext context) async {
    final localization = TrufiLocalization.of(context);
    final currentLocation =
        context.read<LocationProviderCubit>().state.currentLocation;
    if (currentLocation != null) {
      final TrufiLocation value = TrufiLocation(
        description: localization.searchItemYourLocation,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      onMapTapped(value);
    } else {
      showDialog(
        context: context,
        builder: (context) => buildAlertLocationServicesDenied(context),
      );
    }
  }
}

class _BuildChooseOnMap extends StatelessWidget {
  final ValueChanged<TrufiLocation> onMapTapped;

  const _BuildChooseOnMap(this.onMapTapped);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return SliverToBoxAdapter(
      child: _BuildItem(
        () => _handleOnChooseOnMapTapped(context),
        Icons.place,
        localization.searchItemChooseOnMap,
      ),
    );
  }

  Future<void> _handleOnChooseOnMapTapped(BuildContext context) async {
    final LatLng mapLocation = await ChooseLocationPage.selectPosition(context,
        isOrigin: TypeLocationForm().isOrigin);
    if (mapLocation != null && onMapTapped != null) {
      onMapTapped(TrufiLocation.fromLatLng("Map Marker", mapLocation));
    }
  }
}

class _BuildYourPlaces extends StatelessWidget {
  final ValueChanged<TrufiLocation> onSelected;

  const _BuildYourPlaces({
    @required this.onSelected,
    @required this.locations,
  });

  final List<TrufiLocation> locations;

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final config = context.read<ConfigurationCubit>().state;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final TrufiLocation location = locations[index];
          IconData localIconData = Icons.map;
          if (location.type != null) {
            localIconData = typeToIconData(location.type) ?? localIconData;
          }
          return _BuildItem(
            () {
              if (location != null && onSelected != null) {
                onSelected(location);
              }
            },
            localIconData,
            location.translateValue(config.abbreviations, localization),
            subtitle: location.address,
          );
        },
        childCount: locations.length,
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

  const _BuildObjectList(
    this.title,
    this.iconData,
    this.places,
    this.onSelected,
    this.onStreetTapped,
  );

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final theme = context.watch<ThemeCubit>().state.searchTheme;
    final searchLocationsCubit = context.watch<SearchLocationsCubit>();
    final config = context.watch<ConfigurationCubit>().state;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Title
          if (index == 0) {
            return _BuildTitle(title: title);
          }
          // Item
          final TrufiPlace object = places[index - 1];
          if (object is TrufiLocation) {
            IconData localIconData = iconData;

            // Use special type icon if available, fallback to default
            if (object.type != null) {
              localIconData = typeToIconData(object.type) ?? iconData;
            }

            return _BuildItem(
              () {
                if (object != null) {
                  searchLocationsCubit.insertHistoryPlace(object);
                  if (onSelected != null) {
                    onSelected(object);
                  }
                }
              },
              localIconData,
              object.translateValue(config.abbreviations, localization),
              subtitle: object.address,
              trailing: FavoriteButton(
                location: object,
                color: theme.primaryIconTheme.color,
              ),
            );
          } else if (object is TrufiStreet) {
            return _BuildItem(
              () {
                if (object != null) {
                  if (onStreetTapped != null) {
                    onStreetTapped(object);
                  }
                }
              },
              Icons.label,
              object.displayName(config.abbreviations),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: theme.primaryIconTheme.color,
              ),
            );
          }
          return Container();
        },
        childCount: places.isNotEmpty ? places.length + 1 : 0,
      ),
    );
  }
}

class _BuildErrorList extends StatelessWidget {
  final String title;
  final String error;

  const _BuildErrorList({
    Key key,
    @required this.title,
    @required this.error,
  }) : super(key: key);

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

  const _BuildTitle({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state.searchTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Row(
        children: <Widget>[
          Container(padding: const EdgeInsets.all(4.0)),
          RichText(
            text: TextSpan(
              text: title.toUpperCase(),
              style: theme.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildErrorItem extends StatelessWidget {
  final String title;

  const _BuildErrorItem({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BuildItem(null, Icons.error, title);
  }
}

class _BuildItem extends StatelessWidget {
  final void Function() onTap;
  final IconData iconData;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _BuildItem(
    this.onTap,
    this.iconData,
    this.title, {
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state.searchTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Icon(iconData, color: theme.primaryIconTheme.color),
            const SizedBox(width: 32.0, height: 48.0),
            Expanded(
              child: RichText(
                maxLines: 1,
                text: TextSpan(
                  style: theme.textTheme.bodyText2,
                  children: <TextSpan>[
                    TextSpan(text: title),
                    const TextSpan(text: "     "),
                    TextSpan(
                      text: subtitle,
                      style: TextStyle(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (trailing != null) trailing
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import '../blocs/favorite_locations_bloc.dart';
import '../blocs/history_locations_bloc.dart';
import '../blocs/location_provider_bloc.dart';
import '../blocs/location_search_bloc.dart';
import '../blocs/request_manager_bloc.dart';
import '../blocs/saved_places_bloc.dart';
import '../custom_icons.dart';
import '../pages/choose_location.dart';
import '../trufi_models.dart';
import '../widgets/alerts.dart';
import '../widgets/favorite_button.dart';

class LocationSearchDelegate extends SearchDelegate<TrufiLocation> {
  LocationSearchDelegate({this.currentLocation});

  final TrufiLocation currentLocation;

  dynamic _result;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryColorBrightness: Brightness.light,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.black54),
      textTheme: theme.primaryTextTheme.copyWith(
        title: theme.primaryTextTheme.body1.copyWith(color: Colors.black),
        body1: theme.primaryTextTheme.body1.copyWith(color: Colors.black),
        body2: theme.primaryTextTheme.body2.copyWith(color: theme.accentColor),
      ),
    );
  }

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
        close(context, _result);
      },
      onMapTapped: (TrufiLocation location) {
        _result = location;
        showResults(context);
      },
      onStreetTapped: (TrufiStreet street) {
        _result = street;
        showResults(context);
      },
      currentLocation: currentLocation,
      historyLocationsBloc: HistoryLocationsBloc.of(context),
      favoriteLocationsBloc: FavoriteLocationsBloc.of(context),
      locationSearchBloc: LocationSearchBloc.of(context),
      savedPlacesBloc: SavedPlacesBloc.of(context),
      appBarTheme: appBarTheme(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (_result != null) {
      if (_result is TrufiLocation) {
        Future.delayed(Duration.zero, () {
          close(context, _result);
        });
      }
      if (_result is TrufiStreet) {
        return _buildStreetResults(context, _result);
      }
    }
    return buildSuggestions(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              icon: const Icon(null),
              onPressed: () {},
            )
          : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            ),
    ];
  }

  Widget _buildStreetResults(BuildContext context, TrufiStreet street) {
    List<Widget> slivers = [];
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    slivers.add(_buildStreetResultList(context, street));
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    return SafeArea(
      bottom: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(slivers: slivers),
      ),
    );
  }

  Widget _buildStreetResultList(
    BuildContext context,
    TrufiStreet street,
  ) {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    final historyLocationBloc = HistoryLocationsBloc.of(context);
    final localization = TrufiLocalization.of(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Center
          if (index == 0) {
            return _buildItem(
              context,
              appBarTheme(context),
              () {
                historyLocationBloc.inAddLocation.add(street.location);
                close(context, street.location);
              },
              Icons.label,
              street.displayName,
              trailing: FavoriteButton(
                location: street.location,
                favoritesStream: favoriteLocationsBloc.outLocations,
                color: appBarTheme(context).primaryIconTheme.color,
              ),
            );
          }
          // Junctions
          final junction = street.junctions[index - 1];
          return _buildItem(
            context,
            appBarTheme(context),
            () {
              historyLocationBloc.inAddLocation.add(
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
              favoritesStream: favoriteLocationsBloc.outLocations,
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
  _SuggestionList({
    this.query,
    this.onSelected,
    this.onMapTapped,
    this.onStreetTapped,
    this.currentLocation,
    @required this.historyLocationsBloc,
    @required this.favoriteLocationsBloc,
    @required this.locationSearchBloc,
    @required this.savedPlacesBloc,
    @required this.appBarTheme,
  });

  final HistoryLocationsBloc historyLocationsBloc;
  final FavoriteLocationsBloc favoriteLocationsBloc;
  final SavedPlacesBloc savedPlacesBloc;
  final LocationSearchBloc locationSearchBloc;
  final String query;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiLocation> onMapTapped;
  final ValueChanged<TrufiStreet> onStreetTapped;
  final TrufiLocation currentLocation;
  final ThemeData appBarTheme;

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = [];
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    slivers.add(_buildYourLocation(context));
    slivers.add(_buildChooseOnMap(context));
    slivers.add(_buildYourPlaces(context));
    if (query.isEmpty) {
      slivers.add(_buildHistoryList(context));
      slivers.add(_buildFavoritesList(context));
      slivers.add(_buildPlacesList(context));
    } else {
      slivers.add(_buildSearchResultList(context));
    }
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(slivers: slivers),
      ),
    );
  }

  Widget _buildYourLocation(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return SliverToBoxAdapter(
      child: _buildItem(
        context,
        appBarTheme,
        () => _handleOnYourLocationTapped(context),
        Icons.gps_fixed,
        localization.searchItemYourLocation,
      ),
    );
  }

  Widget _buildChooseOnMap(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return SliverToBoxAdapter(
      child: _buildItem(
        context,
        appBarTheme,
        () => _handleOnChooseOnMapTapped(context),
        Icons.place,
        localization.searchItemChooseOnMap,
      ),
    );
  }

  Widget _buildYourPlaces(BuildContext context) {
    return StreamBuilder(
      stream: savedPlacesBloc.outLocations,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<TrufiLocation>> snapshot,
      ) {
        return _buildSavedSimpleList(
          Icons.map,
          savedPlacesBloc.locations.reversed.toList(),
        );
      },
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return _buildFutureBuilder(
      context,
      localization.searchTitleRecent,
      historyLocationsBloc.fetchWithLimit(context, 5),
      Icons.history,
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return StreamBuilder(
      stream: favoriteLocationsBloc.outLocations,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<TrufiLocation>> snapshot,
      ) {
        return _buildObjectList(
          localization.searchTitleFavorites,
          Icons.place,
          favoriteLocationsBloc.locations,
        );
      },
    );
  }

  Widget _buildPlacesList(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return _buildFutureBuilder(
      context,
      localization.searchTitlePlaces,
      locationSearchBloc.fetchPlaces(context),
      Icons.place,
    );
  }

  Widget _buildSearchResultList(BuildContext context) {
    final requestManagerBloc = RequestManagerBloc.of(context);
    final localization = TrufiLocalization.of(context);
    return _buildFutureBuilder(
      context,
      localization.searchTitleResults,
      requestManagerBloc.fetchLocations(
        FavoriteLocationsBloc.of(context),
        LocationSearchBloc.of(context),
        PreferencesBloc.of(context),
        query,
        limit: 30,
      ),
      Icons.place,
      isVisibleWhenEmpty: true,
    );
  }

  Widget _buildFutureBuilder(
    BuildContext context,
    String title,
    Future<List<TrufiPlace>> future,
    IconData iconData, {
    bool isVisibleWhenEmpty = false,
  }) {
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
          print(snapshot.error);
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
          return _buildErrorList(context, title, error);
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
        int count = snapshot.data.length > 0 ? snapshot.data.length + 1 : 0;
        if (count == 0 && isVisibleWhenEmpty) {
          return SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _buildTitle(context, title),
                _buildErrorItem(context, localization.searchItemNoResults),
              ],
            ),
          );
        }
        // Items
        return _buildObjectList(title, iconData, snapshot.data);
      },
    );
  }

  Widget _buildErrorList(BuildContext context, String title, String error) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildTitle(context, title),
          _buildErrorItem(context, error),
        ],
      ),
    );
  }

  IconData _typeToIconData(String type) {
    switch (type) {
      case 'amenity:bar':
      case 'amenity:pub':
      case 'amenity:biergarten':
      case 'amenity:nightclub':
        return Icons.local_bar;

      case 'amenity:cafe':
        return Icons.local_cafe;

      case 'amenity:cinema':
        return Icons.local_movies;

      case 'amenity:pharmacy':
        return Icons.local_pharmacy;

      case 'amenity:fast_food':
        return Icons.fastfood;

      case 'amenity:food_court':
      case 'amenity:restaurant':
        return Icons.restaurant;

      case 'amenity:theatre':
        return Icons.local_play;

      case 'amenity:parking':
        return Icons.local_parking;

      case 'amenity:doctors':
      case 'amenity:dentist':
      case 'amenity:veterinary':
      case 'amenity:clinic':
      case 'amenity:hospital':
        return Icons.local_hospital;

      case 'amenity:library':
        return Icons.local_library;

      case 'amenity:car_wash':
        return Icons.local_car_wash;

      case 'amenity:university':
      case 'amenity:school':
      case 'amenity:college':
        return Icons.school;

      case 'amenity:post_office':
        return Icons.local_post_office;

      case 'amenity:atm':
        return Icons.local_atm;

      case 'amenity:convenience':
        return Icons.local_convenience_store;

      case 'amenity:telephone':
        return Icons.local_phone;

      case 'amenity:internet_cafe':
        return Icons.alternate_email;

      case 'amenity:drinking_water':
        return Icons.local_drink;

      case 'amenity:charging_station':
        return Icons.ev_station;

      case 'amenity:fuel':
        return Icons.local_gas_station;

      case 'amenity:taxi':
        return Icons.local_taxi;

      case 'public_transport:platform':
        return CustomIcons.bus_stop;

      case 'shop:florist':
        return Icons.local_florist;

      case 'shop:convenience':
        return Icons.local_convenience_store;

      case 'shop:supermarket':
        return Icons.local_grocery_store;

      case 'shop:laundry':
        return Icons.local_laundry_service;

      case 'shop:copyshop':
        return Icons.local_printshop;

      case 'shop:mall':
        return Icons.local_mall;

      case 'tourism:hotel':
      case 'tourism:hostel':
      case 'tourism:guest_house':
      case 'tourism:motel':
      case 'tourism:apartment':
        return Icons.local_hotel;

      case 'saved_place:fastfood':
        return Icons.fastfood;

      case 'saved_place:home':
        return Icons.home;

      case 'saved_place:local_cafe':
        return Icons.local_cafe;

      case 'saved_place:map':
        return Icons.map;

      case 'saved_place:work':
        return Icons.work;

      case 'saved_place:school':
        return Icons.school;

      default:
        return null;
    }
  }

  Widget _buildObjectList(
    String title,
    IconData iconData,
    List<TrufiPlace> places,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Title
          if (index == 0) {
            return _buildTitle(context, title);
          }
          // Item
          final object = places[index - 1];
          if (object is TrufiLocation) {
            IconData localIconData = iconData;

            // Use special type icon if available, fallback to default
            if (object.type != null) {
              localIconData = _typeToIconData(object.type) ?? iconData;
            }

            return _buildItem(
              context,
              appBarTheme,
              () => _handleOnLocationTapped(object, addToHistory: true),
              localIconData,
              object.displayName,
              subtitle: object.address,
              trailing: FavoriteButton(
                location: object,
                favoritesStream: favoriteLocationsBloc.outLocations,
                color: appBarTheme.primaryIconTheme.color,
              ),
            );
          } else if (object is TrufiStreet) {
            return _buildItem(
              context,
              appBarTheme,
              () => _handleOnStreetTapped(object),
              Icons.label,
              object.displayName,
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: appBarTheme.primaryIconTheme.color,
              ),
            );
          }
          return Container();
        },
        childCount: places.length > 0 ? places.length + 1 : 0,
      ),
    );
  }

  Widget _buildSavedSimpleList(
    IconData iconData,
    List<TrufiLocation> objects,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final TrufiLocation object = objects[index];
          IconData localIconData = iconData;
          // Use special type icon if available, fallback to default
          if (object.type != null) {
            localIconData = _typeToIconData(object.type) ?? iconData;
          }
          return _buildItem(
            context,
            appBarTheme,
            () => _handleOnLocationTapped(object, addToHistory: true),
            localIconData,
            object.displayName,
            subtitle: object.address,
          );
        },
        childCount: objects.length,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Row(
        children: <Widget>[
          Container(padding: EdgeInsets.all(4.0)),
          RichText(
            text: TextSpan(
              text: title.toUpperCase(),
              style: appBarTheme.textTheme.body2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(BuildContext context, String title) {
    return _buildItem(context, appBarTheme, null, Icons.error, title);
  }

  void _handleOnYourLocationTapped(BuildContext context) async {
    final localization = TrufiLocalization.of(context);
    final location = await LocationProviderBloc.of(context).currentLocation;
    if (location != null) {
      _handleOnLatLngTapped(
        description: localization.searchMapMarker,
        location: location,
        addToHistory: false,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }

  void _handleOnChooseOnMapTapped(BuildContext context) async {
    final localization = TrufiLocalization.of(context);
    LatLng mapLocation = await Navigator.of(context).push(
      MaterialPageRoute<LatLng>(
        builder: (context) => ChooseLocationPage(
          initialPosition: currentLocation != null
              ? LatLng(
                  currentLocation.latitude,
                  currentLocation.longitude,
                )
              : null,
        ),
      ),
    );
    _handleOnMapTapped(
      description: localization.searchMapMarker,
      location: mapLocation,
    );
  }

  void _handleOnLatLngTapped({
    @required String description,
    @required LatLng location,
    bool addToHistory,
  }) {
    _handleOnLocationTapped(
      TrufiLocation(
        description: description,
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      addToHistory: addToHistory,
    );
  }

  void _handleOnLocationTapped(
    TrufiLocation value, {
    bool addToHistory,
  }) {
    if (value != null) {
      if (addToHistory) {
        historyLocationsBloc.inAddLocation.add(value);
      }
      if (onSelected != null) {
        onSelected(value);
      }
    }
  }

  void _handleOnMapTapped({String description, LatLng location}) {
    if (location != null) {
      if (onMapTapped != null) {
        onMapTapped(TrufiLocation.fromLatLng(description, location));
      }
    }
  }

  void _handleOnStreetTapped(TrufiStreet street) {
    if (street != null) {
      if (onStreetTapped != null) {
        onStreetTapped(street);
      }
    }
  }
}

Widget _buildItem(
  BuildContext context,
  ThemeData theme,
  Function onTap,
  IconData iconData,
  String title, {
  String subtitle,
  Widget trailing,
}) {
  Row row = Row(
    children: <Widget>[
      Icon(iconData, color: theme.primaryIconTheme.color),
      Container(width: 32.0, height: 48.0),
      Expanded(
        child: RichText(
          maxLines: 1,
          overflow: TextOverflow.clip,
          text: TextSpan(
            style: theme.textTheme.body1,
            children: <TextSpan>[
              TextSpan(text: title),
              TextSpan(text: "     "),
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
    ],
  );
  if (trailing != null) {
    row.children.add(trailing);
  }
  return InkWell(
    onTap: onTap,
    child: Container(margin: EdgeInsets.symmetric(horizontal: 8.0), child: row),
  );
}

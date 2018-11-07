import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/important_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/pages/choose_location.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/widgets/alerts.dart';
import 'package:trufi_app/widgets/favorite_button.dart';

class LocationSearchDelegate extends SearchDelegate<TrufiLocation> {
  TrufiLocation _result;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      textTheme: theme.primaryTextTheme.copyWith(
        title: theme.primaryTextTheme.body1,
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
      tooltip: "Back",
      onPressed: () {
        close(context, null);
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
      historyLocationsBloc: HistoryLocationsBloc.of(context),
      favoriteLocationsBloc: FavoriteLocationsBloc.of(context),
      importantLocationsBloc: ImportantLocationsBloc.of(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    if (_result != null) {
      print("${localizations.searchNavigate} ${_result.description}");
      Future.delayed(Duration.zero, () {
        close(context, _result);
      });
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
}

class _SuggestionList extends StatelessWidget {
  _SuggestionList({
    this.query,
    this.onSelected,
    this.onMapTapped,
    @required this.historyLocationsBloc,
    @required this.favoriteLocationsBloc,
    @required this.importantLocationsBloc,
  });

  final HistoryLocationsBloc historyLocationsBloc;
  final FavoriteLocationsBloc favoriteLocationsBloc;
  final ImportantLocationsBloc importantLocationsBloc;
  final String query;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiLocation> onMapTapped;

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = List();
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    slivers.add(_buildYourLocation(context));
    slivers.add(_buildChooseOnMap(context));
    if (query.isEmpty) {
      slivers.add(_buildHistoryList(context));
      slivers.add(_buildFavoritesList(context));
    } else {
      slivers.add(_buildSearchResultList(context));
    }
    slivers.add(_buildPlacesList(context));
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    return SafeArea(
      bottom: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(slivers: slivers),
      ),
    );
  }

  Widget _buildYourLocation(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return SliverToBoxAdapter(
      child: _buildItem(
        context,
        () => _handleOnYourLocationTap(context),
        Icons.gps_fixed,
        localizations.searchItemYourLocation,
      ),
    );
  }

  Widget _buildChooseOnMap(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return SliverToBoxAdapter(
      child: _buildItem(
        context,
        () => _handleOnChooseOnMapTap(context),
        Icons.location_on,
        localizations.searchItemChooseOnMap,
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return _buildFutureBuilder(
      context,
      localizations.searchTitleRecent,
      historyLocationsBloc.fetchWithLimit(context, 5),
      Icons.history,
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return StreamBuilder(
      stream: favoriteLocationsBloc.outLocations,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<TrufiLocation>> snapshot,
      ) {
        return _buildLocationsList(
          localizations.searchTitleFavorites,
          Icons.location_on,
          favoriteLocationsBloc.locations,
        );
      },
    );
  }

  Widget _buildSearchResultList(BuildContext context) {
    final requestManagerBloc = RequestManagerBloc.of(context);
    final localizations = TrufiLocalizations.of(context);
    return _buildFutureBuilder(
      context,
      localizations.searchTitleResults,
      requestManagerBloc.fetchLocations(context, query),
      Icons.location_on,
      isVisibleWhenEmpty: true,
    );
  }

  Widget _buildPlacesList(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return _buildFutureBuilder(
      context,
      localizations.searchTitlePlaces,
      importantLocationsBloc.fetchWithQuery(context, query),
      Icons.location_on,
    );
  }

  Widget _buildFutureBuilder(
    BuildContext context,
    String title,
    Future<List<TrufiLocation>> future,
    IconData iconData, {
    bool isVisibleWhenEmpty = false,
  }) {
    return FutureBuilder(
      future: future,
      initialData: null,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<TrufiLocation>> snapshot,
      ) {
        final localizations = TrufiLocalizations.of(context);
        // Error
        if (snapshot.hasError) {
          print(snapshot.error);
          String error = localizations.commonUnknownError;
          if (snapshot.error is FetchOfflineRequestException) {
            error = "Offline mode is not implemented yet";
          } else if (snapshot.error is FetchOfflineResponseException) {
            error = "Offline mode is not implemented yet";
          } else if (snapshot.error is FetchOnlineRequestException) {
            error = localizations.commonNoInternet;
          } else if (snapshot.error is FetchOnlineResponseException) {
            error = localizations.commonFailLoading;
          }
          return _buildErrorList(context, title, error);
        }
        // Loading
        if (snapshot.data == null) {
          return SliverToBoxAdapter(
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.yellow),
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
                _buildErrorItem(context, localizations.searchItemNoResults),
              ],
            ),
          );
        }
        // Items
        return _buildLocationsList(title, iconData, snapshot.data);
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

  Widget _buildLocationsList(
    String title,
    IconData iconData,
    List<TrufiLocation> locations,
  ) {
    int count = locations.length > 0 ? locations.length + 1 : 0;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Title
          if (index == 0) {
            return _buildTitle(context, title);
          }
          // Item
          final TrufiLocation location = locations[index - 1];
          return _buildItem(
            context,
            () => _handleOnSelectedTrufiLocation(location, addToHistory: true),
            iconData,
            location.description,
            trailing: FavoriteButton(
              location: location,
              favoritesStream: favoriteLocationsBloc.outLocations,
            ),
          );
        },
        childCount: count,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Row(
        children: <Widget>[
          Container(padding: EdgeInsets.all(4.0)),
          RichText(
            text: TextSpan(
              text: title.toUpperCase(),
              style: theme.textTheme.body2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(BuildContext context, String title) {
    return _buildItem(context, null, Icons.error, title);
  }

  Widget _buildItem(
    BuildContext context,
    Function onTap,
    IconData iconData,
    String title, {
    Widget trailing,
  }) {
    final theme = Theme.of(context);
    Row row = Row(
      children: <Widget>[
        Icon(iconData),
        Container(width: 32.0),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.clip,
            text: TextSpan(text: title, style: theme.textTheme.body1),
          ),
        ),
      ],
    );
    if (trailing != null) {
      row.children.add(trailing);
    }
    return InkWell(
      onTap: onTap,
      child: Container(margin: EdgeInsets.all(8.0), child: row),
    );
  }

  void _handleOnYourLocationTap(BuildContext context) async {
    final locationProviderBloc = LocationProviderBloc.of(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _handleOnSelectedLatLng(
        description: TrufiLocalizations.of(context).searchMapMarker,
        location: lastLocation,
        addToHistory: false,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }

  void _handleOnChooseOnMapTap(BuildContext context) async {
    final localizations = TrufiLocalizations.of(context);
    LatLng mapLocation = await Navigator.of(context).push(
      MaterialPageRoute<LatLng>(builder: (context) => ChooseLocationPage()),
    );
    _handleOnMapTapped(
      description: localizations.searchMapMarker,
      location: mapLocation,
    );
  }

  void _handleOnSelectedLatLng({
    @required String description,
    @required LatLng location,
    bool addToHistory,
  }) {
    _handleOnSelectedTrufiLocation(
      TrufiLocation(
        description: description,
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      addToHistory: addToHistory,
    );
  }

  void _handleOnSelectedTrufiLocation(
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
}

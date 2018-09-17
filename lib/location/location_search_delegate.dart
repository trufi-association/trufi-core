import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_location_bloc.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/location/location_search_places.dart';
import 'package:trufi_app/pages/choose_location.dart';
import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/widgets/alerts.dart';

class LocationSearchDelegate extends SearchDelegate<TrufiLocation> {
  TrufiLocation result;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: theme.primaryColor,
      primaryIconTheme: theme.primaryIconTheme,
      primaryColorBrightness: theme.primaryColorBrightness,
      primaryTextTheme: theme.primaryTextTheme,
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
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
        result = suggestion;
        close(context, result);
      },
      onMapTapped: (TrufiLocation location) {
        result = location;
        showResults(context);
      },
      historyLocationsBloc: BlocProvider.of<HistoryLocationsBloc>(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    print("${localizations.searchNavigate} ${result.description}");
    close(context, result);
    return Container();
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
  });

  final HistoryLocationsBloc historyLocationsBloc;
  final String query;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiLocation> onMapTapped;

  @override
  Widget build(BuildContext context) {
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    List<Widget> slivers = List();
    //
    // Alternatives
    //
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    slivers.add(_buildYourLocation(context));
    slivers.add(_buildChooseOnMap(context));
    if (query.isEmpty) {
      //
      // History
      //
      slivers.add(_buildFutureBuilder(
        context,
        localizations.searchTitleRecent,
        historyLocationsBloc.fetchWithLimit(context, 5),
        Icons.history,
      ));
    } else {
      //
      // Search Results
      //
      slivers.add(_buildFutureBuilder(
        context,
        localizations.searchTitleResults,
        api.fetchLocations(context, query),
        Icons.location_on,
        isVisibleWhenEmpty: true,
      ));
    }
    //
    // Places
    //
    slivers.add(_buildFutureBuilder(
      context,
      localizations.searchTitlePlaces,
      Places.instance.fetchLocations(context, query),
      Icons.location_on,
    ));
    //
    // List
    //
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    return SafeArea(
      bottom: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(
          slivers: slivers,
        ),
      ),
    );
  }

  Widget _buildYourLocation(BuildContext context) {
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
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
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return SliverToBoxAdapter(
      child: _buildItem(
        context,
        () => _handleOnChooseOnMapTap(context),
        Icons.location_on,
        localizations.searchItemChooseOnMap,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Row(
        children: <Widget>[
          RichText(
            text: TextSpan(
              text: title.toUpperCase(),
              style: theme.textTheme.body1,
            ),
          ),
        ],
      ),
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
        builder: (BuildContext context,
            AsyncSnapshot<List<TrufiLocation>> snapshot) {
          final FavoriteLocationsBloc favoriteLocationsBloc =
              BlocProvider.of<FavoriteLocationsBloc>(context);
          final TrufiLocalizations localizations =
              TrufiLocalizations.of(context);
          // Error
          if (snapshot.hasError) {
            print(snapshot.error);
            if (snapshot.error is api.FetchRequestException) {
              return SliverToBoxAdapter(
                child: _buildErrorItem(
                  context,
                  localizations.commonNoInternet,
                ),
              );
            } else if (snapshot.error is api.FetchResponseException) {
              return SliverToBoxAdapter(
                child: _buildErrorItem(
                  context,
                  localizations.commonFailLoading,
                ),
              );
            } else {
              return SliverToBoxAdapter(
                child: _buildErrorItem(
                  context,
                  localizations.commonUnknownError,
                ),
              );
            }
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
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Title
                if (index == 0) {
                  return _buildTitle(context, title);
                }
                // Item
                final TrufiLocation value = snapshot.data[index - 1];
                return _buildItem(
                  context,
                  () => _onSelectedTrufiLocation(value, addToHistory: true),
                  iconData,
                  value.description,
                  trailing: FavoriteButton(
                    location: value,
                    favoritesStream: favoriteLocationsBloc.outLocations,
                  ),
                );
              },
              childCount: count,
            ),
          );
        });
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
    ThemeData theme = Theme.of(context);
    Row row = Row(
      children: <Widget>[
        Icon(iconData),
        Container(width: 8.0),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.clip,
            text: TextSpan(
              text: title,
              style: theme.textTheme.body2,
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
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: row,
      ),
    );
  }

  void _handleOnYourLocationTap(BuildContext context) async {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _onSelectedLatLng(
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
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    LatLng mapLocation = await Navigator.of(context).push(
      MaterialPageRoute<LatLng>(builder: (context) {
        return ChooseLocationPage(initialPosition: lastLocation);
      }),
    );
    _onMapTapped(
      description: localizations.searchMapMarker,
      location: mapLocation,
    );
  }

  void _onSelectedLatLng({
    @required String description,
    @required LatLng location,
    bool addToHistory,
  }) {
    _onSelectedTrufiLocation(
      TrufiLocation(
        description: description,
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      addToHistory: addToHistory,
    );
  }

  void _onSelectedTrufiLocation(
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

  void _onMapTapped({
    String description,
    LatLng location,
  }) {
    if (location != null) {
      if (onMapTapped != null) {
        onMapTapped(TrufiLocation.fromLatLng(description, location));
      }
    }
  }
}

class FavoriteButton extends StatefulWidget {
  FavoriteButton({
    Key key,
    this.location,
    @required this.favoritesStream,
  }) : super(key: key);

  final TrufiLocation location;
  final Stream<List<TrufiLocation>> favoritesStream;

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  FavoriteLocationBloc _bloc;

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _createBloc();
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeBloc();
    _createBloc();
  }

  @override
  void dispose() {
    _disposeBloc();
    super.dispose();
  }

  void _createBloc() {
    _bloc = FavoriteLocationBloc(widget.location);
    _subscription = widget.favoritesStream.listen(_bloc.inFavorites.add);
  }

  void _disposeBloc() {
    _subscription.cancel();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FavoriteLocationsBloc favoriteLocationsBloc =
        BlocProvider.of<FavoriteLocationsBloc>(context);
    return StreamBuilder(
      stream: _bloc.outIsFavorite,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data == true) {
          return GestureDetector(
            onTap: () {
              favoriteLocationsBloc.inRemoveLocation.add(
                widget.location,
              );
            },
            child: Icon(Icons.favorite),
          );
        } else {
          return GestureDetector(
            onTap: () {
              favoriteLocationsBloc.inAddLocation.add(
                widget.location,
              );
            },
            child: Icon(Icons.favorite_border),
          );
        }
      },
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_location_bloc.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/location/location_map.dart';
import 'package:trufi_app/location/location_search_places.dart';
import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

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
      tooltip: 'Back',
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
    String text = "${localizations.searchNavigate} ${result.description}";
    return Center(
      child: RaisedButton(
        child: Text(text),
        onPressed: () => _close(context),
      ),
    );
  }

  void _close(BuildContext context) {
    close(context, result);
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
              tooltip: 'Clear',
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
    final ThemeData theme = Theme.of(context);
    List<Widget> slivers = List();
    //
    // Alternatives
    //
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    slivers.add(_buildYourLocation(context, theme));
    slivers.add(_buildChooseOnMap(context, theme));
    if (query.isEmpty) {
      //
      // History
      //
      slivers.add(_buildTitle(theme, localizations.searchTitleRecent));
      slivers.add(_buildFutureBuilder(
        context,
        theme,
        historyLocationsBloc.fetchWithLimit(context, 5),
        Icons.history,
        true,
      ));
    } else {
      //
      // Search Results
      //
      slivers.add(_buildTitle(theme, localizations.searchTitleResults));
      slivers.add(_buildFutureBuilder(
        context,
        theme,
        api.fetchLocations(context, query),
        Icons.location_on,
        true,
      ));
    }
    //
    // Places
    //
    slivers.add(_buildTitle(theme, localizations.searchTitlePlaces));
    slivers.add(_buildFutureBuilder(
      context,
      theme,
      Places.instance.fetchLocations(context, query),
      Icons.location_on,
      true,
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

  Widget _buildYourLocation(BuildContext context, ThemeData theme) {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return SliverToBoxAdapter(
      child: StreamBuilder<LatLng>(
        stream: locationProviderBloc.outLocationUpdate,
        initialData: _initialPosition(),
        builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
          return _buildItem(
              theme,
              () => _handleOnYourLocationTap(context, snapshot.data),
              Icons.gps_fixed,
              localizations.searchItemYourLocation);
        },
      ),
    );
  }

  Widget _buildChooseOnMap(BuildContext context, ThemeData theme) {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return SliverToBoxAdapter(
      child: StreamBuilder<LatLng>(
          stream: locationProviderBloc.outLocationUpdate,
          initialData: _initialPosition(),
          builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
            return _buildItem(
                theme,
                () => _handleOnChooseOnMapTap(context, snapshot.data),
                Icons.location_on,
                localizations.searchItemChooseOnMap);
          }),
    );
  }

  Widget _buildTitle(ThemeData theme, String title) {
    return SliverToBoxAdapter(
      child: Container(
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
      ),
    );
  }

  Widget _buildFutureBuilder(
    BuildContext context,
    ThemeData theme,
    Future<List<TrufiLocation>> future,
    IconData iconData,
    bool isFavoritable,
  ) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context,
            AsyncSnapshot<List<TrufiLocation>> snapshot) {
          final TrufiLocalizations localizations =
              TrufiLocalizations.of(context);
          if (snapshot.hasError) {
            print(snapshot.error);
            if (snapshot.error is api.FetchRequestException) {
              return SliverToBoxAdapter(
                child: _buildErrorItem(theme, localizations.commonNoInternet),
              );
            } else if (snapshot.error is api.FetchResponseException) {
              return SliverToBoxAdapter(
                child: _buildErrorItem(theme, localizations.commonFailLoading),
              );
            } else {
              return SliverToBoxAdapter(
                child: _buildErrorItem(theme, localizations.commonUnknownError),
              );
            }
          }
          if (snapshot.data == null) {
            return SliverToBoxAdapter(
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.yellow),
              ),
            );
          }
          final FavoriteLocationsBloc favoriteLocationsBloc =
              BlocProvider.of<FavoriteLocationsBloc>(context);
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final TrufiLocation value = snapshot.data[index];
                return _buildItem(
                  theme,
                  () => _onSelectedTrufiLocation(value),
                  iconData,
                  value.description,
                  trailing: isFavoritable
                      ? FavoriteButton(
                          location: value,
                          favoritesStream: favoriteLocationsBloc.outLocations,
                        )
                      : null,
                );
              },
              childCount: snapshot.data.length,
            ),
          );
        });
  }

  Widget _buildErrorItem(ThemeData theme, String title) {
    return _buildItem(theme, null, Icons.error, title);
  }

  Widget _buildItem(
    ThemeData theme,
    Function onTap,
    IconData iconData,
    String title, {
    Widget trailing,
  }) {
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

  void _handleOnYourLocationTap(BuildContext context, LatLng yourLocation) {
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    _onSelectedLatLng(localizations.searchMapMarker, yourLocation);
  }

  void _handleOnChooseOnMapTap(
    BuildContext context,
    LatLng initialPosition,
  ) async {
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    _onMapTapped(
      localizations.searchMapMarker,
      await Navigator.push(
        context,
        MaterialPageRoute<LatLng>(
          builder: (context) => ChooseOnMapScreen(initialPosition),
        ),
      ),
    );
  }

  void _onSelectedLatLng(String description, LatLng value) {
    if (value != null) {
      _onSelectedTrufiLocation(
        TrufiLocation(
          description: description,
          latitude: value.latitude,
          longitude: value.longitude,
        ),
      );
    }
  }

  void _onSelectedTrufiLocation(TrufiLocation value) {
    if (value != null) {
      historyLocationsBloc.inAddLocation.add(value);
      if (onSelected != null) {
        onSelected(value);
      }
    }
  }

  void _onMapTapped(String description, LatLng value) {
    if (value != null) {
      if (onMapTapped != null) {
        onMapTapped(TrufiLocation.fromLatLng(description, value));
      }
    }
  }

  LatLng _initialPosition() {
    return LatLng(-17.413977, -66.165321);
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
            onTap: () =>
                favoriteLocationsBloc.inRemoveLocation.add(widget.location),
            child: Icon(Icons.favorite),
          );
        } else {
          return GestureDetector(
            onTap: () =>
                favoriteLocationsBloc.inAddLocation.add(widget.location),
            child: Icon(Icons.favorite_border),
          );
        }
      },
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_bloc.dart';
import 'package:trufi_app/location/location_map.dart';
import 'package:trufi_app/location/location_search_favorites.dart';
import 'package:trufi_app/location/location_search_history.dart';
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
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    String text =
        "${TrufiLocalizations.of(context).searchNavigate} ${result.description}";
    return Center(
      child: RaisedButton(
        child: Text(text),
        onPressed: () => _close(context),
      ),
    );
  }

  _close(BuildContext context) {
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
  final String query;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiLocation> onMapTapped;

  _SuggestionList({this.query, this.onSelected, this.onMapTapped});

  @override
  Widget build(BuildContext context) {
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
      slivers.add(_buildTitle(
        theme,
        TrufiLocalizations.of(context).searchTitleRecent,
      ));
      slivers.add(_buildFutureBuilder(
        context,
        theme,
        History.instance.fetchLocationsWithLimit(5),
        Icons.history,
        true,
      ));
    } else {
      //
      // Search Results
      //
      slivers.add(_buildTitle(
        theme,
        TrufiLocalizations.of(context).searchTitleResults,
      ));
      slivers.add(_buildFutureBuilder(
        context,
        theme,
        api.fetchLocations(query),
        Icons.location_on,
        true,
      ));
    }
    //
    // Places
    //
    slivers.add(_buildTitle(
      theme,
      TrufiLocalizations.of(context).searchTitlePlaces,
    ));
    slivers.add(_buildFutureBuilder(
      context,
      theme,
      Places.instance.fetchLocations(query),
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
    LocationBloc locationBloc = BlocProvider.of<LocationBloc>(context);
    return SliverToBoxAdapter(
      child: StreamBuilder<LatLng>(
        stream: locationBloc.outLocationUpdate,
        initialData: _initialPosition(),
        builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
          return _buildItem(
              theme,
              () => _handleOnYourLocationTap(context, snapshot.data),
              Icons.gps_fixed,
              TrufiLocalizations.of(context).searchItemYourLocation);
        },
      ),
    );
  }

  Widget _buildChooseOnMap(BuildContext context, ThemeData theme) {
    LocationBloc locationBloc = BlocProvider.of<LocationBloc>(context);
    return SliverToBoxAdapter(
      child: StreamBuilder<LatLng>(
          stream: locationBloc.outLocationUpdate,
          initialData: _initialPosition(),
          builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
            return _buildItem(
                theme,
                () => _handleOnChooseOnMapTap(context, snapshot.data),
                Icons.location_on,
                TrufiLocalizations.of(context).searchItemChooseOnMap);
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
      bool isFavoritable) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context,
            AsyncSnapshot<List<TrufiLocation>> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            if (snapshot.error is api.FetchRequestException) {
              return SliverToBoxAdapter(
                child: _buildErrorItem(
                  theme,
                  TrufiLocalizations.of(context).commonNoInternet,
                ),
              );
            } else if (snapshot.error is api.FetchResponseException) {
              return SliverToBoxAdapter(
                child: _buildErrorItem(
                  theme,
                  TrufiLocalizations.of(context).commonFailLoading,
                ),
              );
            } else {
              return SliverToBoxAdapter(
                child: _buildErrorItem(
                  theme,
                  TrufiLocalizations.of(context).commonUnknownError,
                ),
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
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final TrufiLocation value = snapshot.data[index];
              return _buildItem(theme, () => _onSelectedTrufiLocation(value),
                  iconData, value.description,
                  trailing: isFavoritable ? FavoriteButton(value) : null);
            }, childCount: snapshot.data.length),
          );
        });
  }

  Widget _buildErrorItem(ThemeData theme, String title) {
    return _buildItem(theme, null, Icons.error, title);
  }

  Widget _buildItem(
      ThemeData theme, Function onTap, IconData iconData, String title,
      {Widget trailing}) {
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
    _onSelectedLatLng(
        TrufiLocalizations.of(context).searchMapMarker, yourLocation);
  }

  void _handleOnChooseOnMapTap(
      BuildContext context, LatLng initialPosition) async {
    _onMapTapped(
      TrufiLocalizations.of(context).searchMapMarker,
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
      History.instance.add(value);
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
  final TrufiLocation location;

  FavoriteButton(this.location);

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    bool _isFavorite = Favorites.instance.contains(widget.location);
    return GestureDetector(
      onTap: () {
        if (_isFavorite) {
          Favorites.instance.remove(widget.location);
        } else {
          Favorites.instance.add(widget.location);
        }
        setState(() {});
      },
      child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
    );
  }
}

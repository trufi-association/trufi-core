import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/location/location_map.dart';
import 'package:trufi_app/location/location_search_favorites.dart';
import 'package:trufi_app/location/location_search_history.dart';
import 'package:trufi_app/location/location_search_places.dart';
import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

class LocationSearchDelegate extends SearchDelegate<TrufiLocation> {
  final LatLng yourLocation;

  TrufiLocation result;

  LocationSearchDelegate({this.yourLocation});

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
      yourLocation: yourLocation,
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
    return Center(
      child: RaisedButton(
        child: Text("Navigate to ${result.description}"),
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
  final LatLng yourLocation;
  final ValueChanged<TrufiLocation> onSelected;
  final ValueChanged<TrufiLocation> onMapTapped;

  _SuggestionList(
      {this.query, this.yourLocation, this.onSelected, this.onMapTapped});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    List<Widget> slivers = List();
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    if (yourLocation != null) {
      slivers.add(_buildYourLocation(context, theme));
    }
    slivers.add(_buildChooseOnMap(context, theme));
    if (query.isEmpty) {
      slivers.add(
          _buildTitle(theme, TrufiLocalizations.of(context).searchTitleRecent));
      slivers.add(_buildFutureBuilder(context, theme,
          History.instance.fetchLocationsWithLimit(5), Icons.history, true));
    } else {
      slivers.add(_buildTitle(
          theme, TrufiLocalizations.of(context).searchTitleResults));
      slivers.add(_buildFutureBuilder(
          context, theme, api.fetchLocations(query), Icons.location_on, true));
    }
    slivers.add(
        _buildTitle(theme, TrufiLocalizations.of(context).searchTitlePlaces));
    slivers.add(_buildFutureBuilder(context, theme,
        Places.instance.fetchLocations(query), Icons.location_on, true));
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
    return SliverToBoxAdapter(
        child: _buildItem(
            theme,
            () => _handleOnYourLocationTap(),
            Icons.gps_fixed,
            TrufiLocalizations.of(context).searchItemYourLocation));
  }

  Widget _buildChooseOnMap(BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: _buildItem(
          theme,
          () => _handleOnChooseOnMapTap(context),
          Icons.location_on,
          TrufiLocalizations.of(context).searchItemChooseOnMap),
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
                child: _buildErrorItem(theme, "No internet connection"),
              );
            } else if (snapshot.error is api.FetchResponseException) {
              return SliverToBoxAdapter(
                child: _buildErrorItem(theme, "Failed to load data"),
              );
            } else {
              return SliverToBoxAdapter(
                child: _buildErrorItem(theme, "Unknown error"),
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

  _handleOnYourLocationTap() {
    _onSelectedLatLng(yourLocation);
  }

  _handleOnChooseOnMapTap(BuildContext context) async {
    _onMapTapped(
      await Navigator.push(
        context,
        MaterialPageRoute<LatLng>(
          builder: (context) => ChooseOnMapScreen(position: yourLocation),
        ),
      ),
    );
  }

  _onSelectedLatLng(LatLng value) {
    if (value != null) {
      _onSelectedTrufiLocation(
        TrufiLocation(
          description: "Map Marker",
          latitude: value.latitude,
          longitude: value.longitude,
        ),
      );
    }
  }

  _onSelectedTrufiLocation(TrufiLocation value) {
    if (value != null) {
      History.instance.add(value);
      if (onSelected != null) {
        onSelected(value);
      }
    }
  }

  _onMapTapped(LatLng value) {
    if (value != null) {
      if (onMapTapped != null) {
        onMapTapped(TrufiLocation.fromLatLng("Map Marker", value));
      }
    }
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

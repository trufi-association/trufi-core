import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_places.dart' as places;
import 'package:trufi_app/location/location_map.dart';
import 'package:trufi_app/location/location_search_history.dart' as history;

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
        query = suggestion.description;
        result = suggestion;
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

  _SuggestionList({this.query, this.yourLocation, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    List<Widget> slivers = List();
    slivers.add(SliverPadding(padding: EdgeInsets.all(4.0)));
    if (yourLocation != null) {
      slivers.add(_buildYourLocation(theme));
    }
    slivers.add(_buildChooseOnMap(context, theme));
    if (query.isEmpty) {
      slivers.add(_buildTitle(theme, "Recent"));
      slivers.add(_buildFutureBuilder(
          context, theme, history.fetchLocations(5), Icons.history));
    } else {
      slivers.add(_buildTitle(theme, "Search Results"));
      slivers.add(_buildFutureBuilder(
          context, theme, api.fetchLocations(query), Icons.location_on));
    }
    slivers.add(_buildTitle(theme, "Places"));
    slivers.add(_buildFutureBuilder(context, theme,
        places.fetchLocations(context, query), Icons.location_on));
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

  _buildYourLocation(ThemeData theme) {
    return SliverToBoxAdapter(
      child: _buildItem(theme, () => _handleOnYourLocationTap(),
          Icons.gps_fixed, "Your location"),
    );
  }

  _buildChooseOnMap(BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: _buildItem(theme, () => _handleOnChooseOnMapTap(context),
          Icons.location_on, "Choose on map"),
    );
  }

  _buildTitle(ThemeData theme, String title) {
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

  _buildFutureBuilder(BuildContext context, ThemeData theme,
      Future<List<TrufiLocation>> future, IconData iconData) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context,
            AsyncSnapshot<List<TrufiLocation>> snapshot) {
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
              return _buildItem(theme, () => _selectTrufiLocation(value),
                  iconData, value.description);
            }, childCount: snapshot.data.length),
          );
        });
  }

  _buildItem(ThemeData theme, Function onTap, IconData iconData, String title) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(2.0),
        child: Row(
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
        ),
      ),
    );
  }

  _handleOnYourLocationTap() {
    _selectLatLng(yourLocation);
  }

  _handleOnChooseOnMapTap(BuildContext context) async {
    _selectLatLng(
      await Navigator.push(
        context,
        MaterialPageRoute<LatLng>(
          builder: (context) => ChooseOnMapScreen(position: yourLocation),
        ),
      ),
    );
  }

  _selectLatLng(LatLng value) {
    if (value == null) return;
    _selectTrufiLocation(
      TrufiLocation(
        description: "Map Marker",
        latitude: value.latitude,
        longitude: value.longitude,
      ),
    );
  }

  _selectTrufiLocation(TrufiLocation value) {
    history.addLocation(value);
    onSelected(value);
  }
}

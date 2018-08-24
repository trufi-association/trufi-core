import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_places.dart' as places;
import 'package:trufi_app/location/location_search_history.dart' as history;

class LocationSearchDelegate extends SearchDelegate<TrufiLocation> {
  @override
  Widget buildLeading(BuildContext context) {
    return new IconButton(
      tooltip: 'Back',
      icon: new AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return new _SuggestionList(
      query: query,
      onSelected: (TrufiLocation suggestion) {
        query = suggestion.description;
        this.close(context, suggestion);
        //showResults(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return new Center(
      child: new Text(
        'Result: "$query"',
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? new IconButton(
              icon: const Icon(null),
              onPressed: () {},
            )
          : new IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ];
  }
}

class _SuggestionList extends StatelessWidget {
  final String query;
  final ValueChanged<TrufiLocation> onSelected;

  _SuggestionList({this.query, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    List<Widget> slivers = new List();
    slivers.add(new SliverPadding(padding: EdgeInsets.all(4.0)));
    if (query.isEmpty) {
      slivers.add(_buildTitle(theme, "Recent"));
      slivers.add(_buildFutureBuilder(
          context, theme, history.fetchLocations(5), Icons.history));
    } else {
      slivers.add(_buildTitle(theme, "Search Results"));
      slivers.add(_buildFutureBuilder(
          context, theme, api.fetchLocations(query), Icons.history));
    }
    slivers.add(_buildTitle(theme, "Places"));
    slivers.add(_buildFutureBuilder(context, theme,
        places.fetchLocations(context, query), Icons.location_on));
    slivers.add(new SliverPadding(padding: EdgeInsets.all(4.0)));
    return new Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: new CustomScrollView(
        slivers: slivers,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, String title) {
    return new SliverToBoxAdapter(
      child: new Container(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: new Row(
          children: <Widget>[
            new RichText(
              text: new TextSpan(
                text: title.toUpperCase(),
                style: theme.textTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureBuilder(BuildContext context, ThemeData theme,
      Future<List<TrufiLocation>> future, IconData iconData) {
    return new FutureBuilder(
        future: future,
        builder: (BuildContext context,
            AsyncSnapshot<List<TrufiLocation>> suggestions) {
          if (suggestions.data == null) {
            return new SliverToBoxAdapter(
              child: new LinearProgressIndicator(
                valueColor: new AlwaysStoppedAnimation(Colors.yellow),
              ),
            );
          }
          return new SliverList(
            delegate: new SliverChildBuilderDelegate((context, index) {
              final TrufiLocation suggestion = suggestions.data[index];
              return new GestureDetector(
                onTap: () => _handleTap(suggestion),
                child: new Container(
                  margin: EdgeInsets.all(2.0),
                  child: new Row(
                    children: <Widget>[
                      new Icon(iconData),
                      new Container(width: 8.0),
                      new Flexible(
                        child: new RichText(
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          text: new TextSpan(
                            text: suggestion.description,
                            style: theme.textTheme.body1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: suggestions.data.length),
          );
        });
  }

  _handleTap(TrufiLocation value) {
    history.addLocation(value);
    onSelected(value);
  }
}

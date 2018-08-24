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
    if (query.isEmpty) {
      slivers.add(new SliverToBoxAdapter(
        child: new Text("Recent".toUpperCase()),
      ));
      slivers.add(createFutureBuilder(
          context, theme, history.fetchLocations(5), Icons.history));
    } else {
      slivers.add(new SliverToBoxAdapter(
        child: new Text("Search Results".toUpperCase()),
      ));
      slivers.add(createFutureBuilder(
          context, theme, api.fetchLocations(query), Icons.history));
    }
    slivers.add(new SliverToBoxAdapter(
      child: new Text("Places".toUpperCase()),
    ));
    slivers.add(createFutureBuilder(context, theme,
        places.fetchLocations(context, query), Icons.location_on));
    return new Container(
      child: new CustomScrollView(
        slivers: slivers,
      ),
    );
  }

  Widget createFutureBuilder(BuildContext context, ThemeData theme,
      Future<List<TrufiLocation>> future, IconData iconData) {
    return new FutureBuilder(
        future: future,
        initialData: new List<TrufiLocation>(),
        builder: (BuildContext context,
            AsyncSnapshot<List<TrufiLocation>> suggestions) {
          return new SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: new SliverFixedExtentList(
                delegate: new SliverChildBuilderDelegate((context, index) {
                  final TrufiLocation suggestion = suggestions.data[index];
                  return new ListTile(
                    leading: new Icon(iconData),
                    title: new RichText(
                      text: new TextSpan(
                        text: suggestion.description,
                        style: theme.textTheme.subhead
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      history.addLocation(suggestion);
                      onSelected(suggestion);
                    },
                  );
                }, childCount: suggestions.data.length),
                itemExtent: 30.0),
          );
        });
  }
}

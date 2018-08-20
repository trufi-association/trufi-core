import 'package:flutter/material.dart';

import 'package:trufi_app/api/location_api.dart';

class LocationSearchDelegate extends SearchDelegate<Location> {

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
      onSelected: (Location suggestion) {
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
  _SuggestionList({this.query, this.onSelected});

  final String query;
  final ValueChanged<Location> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new FutureBuilder(
        future: fetchLocations(query),
        initialData: List<Location>(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Location>> suggestions) {
          return new Container(
              child: new ListView.builder(
            itemCount: suggestions.data.length,
            itemBuilder: (BuildContext context, int i) {
              final Location suggestion = suggestions.data[i];
              return new ListTile(
                leading: const Icon(Icons.location_on),
                title: new RichText(
                  text: new TextSpan(
                    text: suggestion.description,
                    style: theme.textTheme.subhead
                        .copyWith(fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      new TextSpan(
                        text: 'lat:${suggestion.latitude}) lng:${suggestion
                                .longitude}',
                        style: theme.textTheme.subhead,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  onSelected(suggestion);
                },
              );
            },
          ));
        });
  }
}

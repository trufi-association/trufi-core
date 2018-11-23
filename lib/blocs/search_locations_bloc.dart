import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/locations_bloc_base.dart';
import 'package:trufi_app/location/location_storage.dart';
import 'package:trufi_app/trufi_models.dart';

class SearchLocationsBloc extends LocationsBlocBase {
  static SearchLocationsBloc of(BuildContext context) {
    return BlocProvider.of<SearchLocationsBloc>(context);
  }

  SearchLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          JSONLocationStorage("assets/data/locations.json"),
        );

  @override
  Future<List<LevenshteinTrufiLocation>> fetchWithQuery(
    BuildContext context,
    String query,
  ) async {
    final locations = await super.fetchWithQuery(context, query);
    locations.sort(_sortByImportance);
    return locations;
  }

  int _sortByImportance(
    LevenshteinTrufiLocation a,
    LevenshteinTrufiLocation b,
  ) {
    if (a.location.importance != null && b.location.importance != null) {
      return a.location.importance.compareTo(b.location.importance) * -1;
    }
    return 0;
  }
}

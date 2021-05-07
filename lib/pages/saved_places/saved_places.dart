import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/saved_places/location_tiler.dart';

import '../../trufi_models.dart';
import '../../widgets/set_description_dialog.dart';
import '../../widgets/trufi_drawer.dart';
import '../choose_location.dart';

class SavedPlacesPage extends StatelessWidget {
  static const String route = '/places';

  const SavedPlacesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TrufiLocalization localization = TrufiLocalization.of(context);
    final theme = Theme.of(context);
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(localization.menuYourPlaces)),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            TabBar(
              tabs: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Saved places",
                    style: theme.textTheme.bodyText1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Favorite places",
                    style: theme.textTheme.bodyText1,
                  ),
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Scaffold(
                    body: BlocBuilder<SearchLocationsCubit, SearchLocationsState>(
                      builder: (context, state) {
                        final List<TrufiLocation> data = searchLocationsCubit.state.myPlaces;
                        return ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return LocationTiler(
                                location: data[index],
                                enableSetIcon: true,
                                enableSetName: true,
                                enableSetPosition: true,
                                updateLocation: searchLocationsCubit.updateMyPlace,
                                removeLocation: searchLocationsCubit.deleteMyPlace);
                          },
                        );
                      },
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        // _addNewPlace(context);
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      heroTag: null,
                      child: const Icon(Icons.add),
                    ),
                  ),
                  BlocBuilder<SearchLocationsCubit, SearchLocationsState>(
                    builder: (context, state) {
                      final List<TrufiLocation> data = [
                        // ...searchLocationsCubit.state.myPlaces.reversed.toList(),
                        ...state.favoritePlaces
                      ];
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return LocationTiler(
                            location: data[index],
                            enableSetIcon: true,
                            updateLocation: searchLocationsCubit.updateFavoritePlace,
                            removeLocation: searchLocationsCubit.deleteFavoritePlace,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: const TrufiDrawer(SavedPlacesPage.route),
    );
  }

  Future<void> _addNewPlace(BuildContext context) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final LatLng mapLocation = await ChooseLocationPage.selectPosition(context);
    if (mapLocation != null) {
      final String description = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SetDescriptionDialog();
        },
      );
      if (description != null) {
        searchLocationsCubit.insertMyPlace(TrufiLocation(
          description: description,
          latitude: mapLocation.latitude,
          longitude: mapLocation.longitude,
          type: 'saved_place:map',
        ));
      }
    }
  }
}

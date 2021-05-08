import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/saved_places/location_tiler.dart';
import 'package:trufi_core/widgets/dialog_edit_text.dart';

import '../../trufi_models.dart';
import '../../widgets/trufi_drawer.dart';
import '../choose_location.dart';

class SavedPlacesPage extends StatelessWidget {
  static const String route = '/places';

  const SavedPlacesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final localization = TrufiLocalization.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localization.menuYourPlaces)),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            TabBar(
              tabs: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    // TODO translate
                    "Saved places",
                    style: theme.textTheme.bodyText1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    // TODO translate
                    "Favorite places",
                    style: theme.textTheme.bodyText1,
                    maxLines: 2,
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: TabBarView(
                children: [
                  Scaffold(
                    body: BlocBuilder<SearchLocationsCubit, SearchLocationsState>(
                      builder: (context, state) {
                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: [
                            const SizedBox(height: 10),
                            Builder(builder: (_) {
                              return Column(
                                children: searchLocationsCubit.state.myDefaultPlaces.map(
                                  (place) {
                                    return LocationTiler(
                                      location: place,
                                      enableSetPosition: true,
                                      isDefaultLocation: true,
                                      updateLocation: searchLocationsCubit.updateMyDefaultPlace,
                                    );
                                  },
                                ).toList(),
                              );
                            }),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              // TODO translate
                              child: Text('Custom Places', style: theme.textTheme.bodyText1),
                            ),
                            Column(
                              children: searchLocationsCubit.state.myPlaces
                                  .map(
                                    (place) => LocationTiler(
                                        location: place,
                                        enableSetIcon: true,
                                        enableSetName: true,
                                        enableSetPosition: true,
                                        updateLocation: searchLocationsCubit.updateMyPlace,
                                        removeLocation: searchLocationsCubit.deleteMyPlace),
                                  )
                                  .toList(),
                            )
                          ],
                        );
                      },
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        _addNewPlace(context);
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      heroTag: null,
                      child: const Icon(Icons.add),
                    ),
                  ),
                  BlocBuilder<SearchLocationsCubit, SearchLocationsState>(
                    builder: (context, state) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.favoritePlaces.length,
                        itemBuilder: (BuildContext context, int index) {
                          return LocationTiler(
                            location: state.favoritePlaces[index],
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
          return const DialogEditText();
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

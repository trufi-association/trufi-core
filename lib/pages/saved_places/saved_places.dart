import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';

import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/saved_places/location_tiler.dart';

import '../../models/trufi_place.dart';
import '../../widgets/trufi_drawer.dart';
import '../choose_location.dart';

class SavedPlacesPage extends StatelessWidget {
  static const String route = '/places';

  const SavedPlacesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final Configuration config = context.read<ConfigurationCubit>().state;
    final currentLocale = Localizations.localeOf(context);
    final localization = TrufiLocalization.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localization.menuYourPlaces)),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Text(
                    localization.menuYourPlaces,
                    style: theme.textTheme.bodyText1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Text(
                    config.customTranslations!.get(
                      config.customTranslations!.commonFavoritePlaces,
                      currentLocale,
                      localization.commonFavoritePlaces,
                    ),
                    style: theme.textTheme.bodyText1,
                    maxLines: 2,
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                color: Colors.grey.withOpacity(.1),
                child: TabBarView(
                  children: [
                    Stack(
                      children: [
                        BlocBuilder<SearchLocationsCubit, SearchLocationsState>(
                          builder: (context, state) {
                            return Scrollbar(
                              child: ListView(
                                children: [
                                  const SizedBox(height: 10),
                                  Column(
                                    children: searchLocationsCubit
                                        .state.myDefaultPlaces
                                        .map(
                                      (place) {
                                        return LocationTiler(
                                          location: place,
                                          enableSetPosition: true,
                                          isDefaultLocation: true,
                                          updateLocation: searchLocationsCubit
                                              .updateMyDefaultPlace,
                                        );
                                      },
                                    ).toList(),
                                  ),
                                  if (searchLocationsCubit
                                      .state.myPlaces.isNotEmpty) ...[
                                    const Divider(),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                          localization.commonCustomPlaces,
                                          style: theme.textTheme.bodyText1),
                                    ),
                                  ],
                                  Column(
                                    children:
                                        searchLocationsCubit.state.myPlaces
                                            .map(
                                              (place) => LocationTiler(
                                                  location: place,
                                                  enableLocation: true,
                                                  updateLocation:
                                                      searchLocationsCubit
                                                          .updateMyPlace,
                                                  removeLocation:
                                                      searchLocationsCubit
                                                          .deleteMyPlace),
                                            )
                                            .toList(),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                        Positioned(
                          right: 15,
                          bottom: 15,
                          child: FloatingActionButton(
                            onPressed: () {
                              _addNewPlace(context);
                            },
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<SearchLocationsCubit, SearchLocationsState>(
                      builder: (context, state) {
                        return Scrollbar(
                          child: ListView.builder(
                            itemCount: state.favoritePlaces.length,
                            itemBuilder: (BuildContext context, int index) {
                              return LocationTiler(
                                location: state.favoritePlaces[index],
                                updateLocation:
                                    searchLocationsCubit.updateFavoritePlace,
                                removeLocation:
                                    searchLocationsCubit.deleteFavoritePlace,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
    final ChooseLocationDetail? chooseLocationDetail =
        await ChooseLocationPage.selectPosition(
      context,
    );
    if (chooseLocationDetail != null) {
      searchLocationsCubit.insertMyPlace(TrufiLocation(
        description: chooseLocationDetail.description,
        address: chooseLocationDetail.street,
        latitude: chooseLocationDetail.location!.latitude,
        longitude: chooseLocationDetail.location!.longitude,
        type: 'saved_place:map',
      ));
    }
  }
}

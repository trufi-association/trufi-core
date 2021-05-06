import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/home_page.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';

import '../blocs/gps_location/location_provider_cubit.dart';
import '../trufi_configuration.dart';
import '../trufi_models.dart';
import '../widgets/set_description_dialog.dart';
import '../widgets/trufi_drawer.dart';
import 'choose_location.dart';
import 'home/plan_map/setting_panel/setting_panel_cubit.dart';

class SavedPlacesPage extends StatefulWidget {
  static const String route = '/places';

  const SavedPlacesPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SavedPlacesPageState();
}

class SavedPlacesPageState extends State<SavedPlacesPage> {
  LatLng _center;

  @override
  void dispose() {
    super.dispose();
  }

  final Map<String, IconData> icons = <String, IconData>{
    'saved_place:home': Icons.home,
    'saved_place:work': Icons.work,
    'saved_place:fastfood': Icons.fastfood,
    'saved_place:local_cafe': Icons.local_cafe,
    'saved_place:map': Icons.map,
    'saved_place:school': Icons.school,
  };

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    final TrufiConfigurationMap map = TrufiConfiguration().map;
    _center = map.center;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: const TrufiDrawer(SavedPlacesPage.route),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final TrufiLocalization localization = TrufiLocalization.of(context);
    return AppBar(title: Text(localization.menuYourPlaces));
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);

    final searchLocationsCubit = context.watch<SearchLocationsCubit>();

    final List<TrufiLocation> data =
        searchLocationsCubit.state.myPlaces.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        final TrufiLocation savedPlace = data[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 5),
          child: ElevatedButton(
            onPressed: () => _showCurrentRoute(savedPlace),
            child: Row(
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(
                      _typeToIconData(savedPlace.type) ?? Icons.place,
                    )),
                Expanded(
                  child: Text(
                    savedPlace.description,
                    style: theme.textTheme.bodyText2,
                    maxLines: 1,
                  ),
                ),
                PopupMenuButton<int>(
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(localization.savedPlacesSetIconLabel),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(localization.savedPlacesSetNameLabel),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text(localization.savedPlacesSetPositionLabel),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Text(localization.savedPlacesRemoveLabel),
                    ),
                  ],
                  onSelected: (int index) async {
                    if (index == 1) {
                      _changeIcon(savedPlace);
                    } else if (index == 2) {
                      _changeName(savedPlace);
                    } else if (index == 3) {
                      _changePosition(savedPlace);
                    } else if (index == 4) {
                      searchLocationsCubit.deleteMyPlace(savedPlace);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _addNewPlace,
      backgroundColor: Theme.of(context).primaryColor,
      heroTag: null,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _showCurrentRoute(TrufiLocation toLocation) async {
    final location = context.read<LocationProviderCubit>().state.currentLocation;
    if (location == null) return;
    final TrufiLocation currentLocation = TrufiLocation.fromLatLng(
      TrufiLocalization.of(context).searchItemYourLocation,
      location,
    );

    final homePageCubit = context.read<HomePageCubit>();
    await homePageCubit.updateCurrentRoute(currentLocation, toLocation);
    final appReviewCubit = context.read<AppReviewCubit>();
    final settingPanelCubit = context.read<SettingPanelCubit>();

    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    await homePageCubit
        .fetchPlan(correlationId,advancedOptions: settingPanelCubit.state)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
    Navigator.pushNamed(context, HomePage.route);
  }

  Future<void> _changeIcon(TrufiLocation savedPlace) async {
    final localization = TrufiLocalization.of(context);
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(localization.savedPlacesSelectIconTitle),
        children: <Widget>[
          SizedBox(
            width: 200,
            height: 200,
            child: GridView.builder(
              itemCount: icons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    final TrufiLocation newLocation = TrufiLocation(
                      description: savedPlace.description,
                      latitude: savedPlace.latitude,
                      longitude: savedPlace.longitude,
                      type: icons.keys.toList()[index],
                    );
                    searchLocationsCubit.updateMyPlace(savedPlace, newLocation);
                    Navigator.pop(context);
                  },
                  child: Icon(icons.values.toList()[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeName(TrufiLocation savedPlace) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final String description = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SetDescriptionDialog(initText: savedPlace.description);
        });
    if (description != null) {
      final TrufiLocation newPlace = TrufiLocation(
        description: description,
        latitude: savedPlace.latitude,
        longitude: savedPlace.longitude,
        type: savedPlace.type,
      );
      searchLocationsCubit.updateMyPlace(
        savedPlace,
        newPlace,
      );
    }
  }

  Future<void> _changePosition(TrufiLocation savedPlace) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final LatLng mapLocation = await _selectPosition(
        LatLng(savedPlace.latitude, savedPlace.longitude));
    if (mapLocation != null) {
      final TrufiLocation newPlace = TrufiLocation(
        description: savedPlace.description,
        latitude: mapLocation.latitude,
        longitude: mapLocation.longitude,
        type: savedPlace.type,
      );

      searchLocationsCubit.updateMyPlace(
        savedPlace,
        newPlace,
      );
    }
  }

  Future<void> _addNewPlace() async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final LatLng mapLocation = await _selectPosition(_center);
    if (mapLocation != null) {
      final String description = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const SetDescriptionDialog();
          });
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

  IconData _typeToIconData(String type) {
    switch (type) {
      case 'saved_place:home':
        return Icons.home;
      case 'saved_place:work':
        return Icons.work;
      case 'saved_place:fastfood':
        return Icons.fastfood;
      case 'saved_place:local_cafe':
        return Icons.local_cafe;
      case 'saved_place:map':
        return Icons.map;
      case 'saved_place:school':
        return Icons.school;
      default:
        return Icons.place;
    }
  }

  Future<LatLng> _selectPosition(LatLng coordinate) {
    return Navigator.of(context).push(
      MaterialPageRoute<LatLng>(
        builder: (BuildContext context) => ChooseLocationPage(),
      ),
    );
  }
}

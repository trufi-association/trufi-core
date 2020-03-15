import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import '../blocs/saved_places_bloc.dart';
import '../blocs/location_provider_bloc.dart';

import '../pages/home.dart';

import '../trufi_configuration.dart';
import '../trufi_localizations.dart';
import '../trufi_models.dart';
import '../widgets/trufi_drawer.dart';
import '../widgets/set_description_dialog.dart';

import 'choose_location.dart';

class SavedPlacesPage extends StatefulWidget {
  static const String route = '/places';

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
      drawer: TrufiDrawer(SavedPlacesPage.route),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final TrufiLocalization localization =
        TrufiLocalizations.of(context).localization;
    return AppBar(title: Text(localization.menuYourPlaces()));
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalizations.of(context).localization;
    final savedPlacesBloc = SavedPlacesBloc.of(context);

    return StreamBuilder(
      initialData: savedPlacesBloc.locations.reversed.toList(),
      stream: savedPlacesBloc.outLocations,
      builder: (BuildContext context, AsyncSnapshot<List<TrufiLocation>> snapshot) {
        final data = snapshot.data.reversed.toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            final TrufiLocation savedPlace = data[index];
            return Container(
              margin: EdgeInsets.only(bottom: 5),
              child: RaisedButton(
                onPressed: () => _showCurrentRoute(savedPlace),
                child: Row(
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(right: 5),
                        child: Icon(
                            _typeToIconData(savedPlace.type) ?? Icons.place)),
                    Expanded(
                      child: Text(
                        savedPlace.description,
                        style: theme.textTheme.body2,
                        maxLines: 1,
                      ),
                    ),
                    PopupMenuButton<int>(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Text(localization.savedPlacesSetIconLabel()),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text(localization.savedPlacesSetNameLabel()),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Text(localization.savedPlacesSetPositionLabel()),
                        ),
                        PopupMenuItem(
                          value: 4,
                          child: Text(localization.savedPlacesRemoveLabel()),
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
                          setState(() {
                            savedPlacesBloc.inRemoveLocation.add(savedPlace);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _addNewPlace,
      child: Icon(Icons.add),
      backgroundColor: Theme.of(context).primaryColor,
      heroTag: null,
    );
  }

  Future<void> _showCurrentRoute(TrufiLocation toLocation) async {
    HomePageStateData dataRoute = HomePageStateData();
    final location = await LocationProviderBloc.of(context).currentLocation;
    if (location == null) return;
    TrufiLocation currentLocation = TrufiLocation.fromLatLng(
      TrufiLocalizations.of(context).localization.searchItemYourLocation(),
      location,
    );
    dataRoute.fromPlace = currentLocation;
    dataRoute.toPlace = toLocation;
    dataRoute.plan = null;
    dataRoute.save(context);
    Navigator.pushNamed(context, HomePage.route);
  }

  Future<void> _changeIcon(TrufiLocation savedPlace) async {
    final localization = TrufiLocalizations.of(context).localization;
    final savedPlacesBloc = SavedPlacesBloc.of(context);
    return await showDialog(
      context: context,
      child: SimpleDialog(
        title: Text(localization.savedPlacesSelectIconTitle()),
        children: <Widget>[
          Container(
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
                    savedPlacesBloc.inReplaceLocation
                        .add(<String, TrufiLocation>{
                          'oldLocation': savedPlace,
                          'newLocation': newLocation
                        });
                    setState(() {});
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
    final savedPlacesBloc = SavedPlacesBloc.of(context);
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
      savedPlacesBloc.inReplaceLocation.add(<String, TrufiLocation>{
        'oldLocation': savedPlace,
        'newLocation': newPlace
      });
    }
  }

  Future<void> _changePosition(TrufiLocation savedPlace) async {
    final savedPlacesBloc = SavedPlacesBloc.of(context);
    final LatLng mapLocation = await _selectPosition(
        LatLng(savedPlace.latitude, savedPlace.longitude));
    if (mapLocation != null) {
      final TrufiLocation newPlace = TrufiLocation(
        description: savedPlace.description,
        latitude: mapLocation.latitude,
        longitude: mapLocation.longitude,
        type: savedPlace.type,
      );

      savedPlacesBloc.inReplaceLocation.add(<String, TrufiLocation>{
        'oldLocation': savedPlace,
        'newLocation': newPlace
      });
      setState(() {});
    }
  }

  Future<void> _addNewPlace() async {
    final savedPlacesBloc = SavedPlacesBloc.of(context);
    final LatLng mapLocation = await _selectPosition(_center);
    if (mapLocation != null) {
      final String description = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SetDescriptionDialog();
          });
      if (description != null) {
        savedPlacesBloc.inAddLocation.add(TrufiLocation(
          description: description,
          latitude: mapLocation.latitude,
          longitude: mapLocation.longitude,
          type: 'saved_place:map',
        ));
      }
    }
    setState(() {});
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
        builder: (BuildContext context) =>
            ChooseLocationPage(initialPosition: coordinate),
      ),
    );
  }
}

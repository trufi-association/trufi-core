import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import '../blocs/saved_locations_bloc.dart';
import '../blocs/location_provider_bloc.dart';

import '../pages/home.dart';

import '../trufi_configuration.dart';
import '../trufi_localizations.dart';
import '../trufi_models.dart';
import '../widgets/trufi_drawer.dart';

import 'choose_location.dart';

class SavedPlacesPage extends StatefulWidget {
  static const String route = '/places';

  @override
  State<StatefulWidget> createState() => SavedPlacesPageState();
}

class SavedPlacesPageState extends State<SavedPlacesPage> {
  LatLng _center;
  TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
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
    final ThemeData theme = Theme.of(context);
    final TrufiLocalization localization =
        TrufiLocalizations.of(context).localization;
    final SavedLocationsBloc savedLocationsBloc =
        SavedLocationsBloc.of(context);
    final List<TrufiLocation> data =
        savedLocationsBloc.locations.reversed.toList();

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
                        child: Text(localization.savedSectionSetIcon()),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text(localization.savedSectionSetCoordinate()),
                      ),
                      PopupMenuItem(
                        value: 3,
                        child: Text(localization.savedSectionRemove()),
                      ),
                    ],
                    onSelected: (int index) async {
                      if (index == 1) {
                        _changeIcon(savedPlace);
                      } else if (index == 2) {
                        _changeCoordinate(savedPlace);
                      } else if (index == 3) {
                        setState(() {
                          savedLocationsBloc.inRemoveLocation.add(savedPlace);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        final LatLng mapLocation = await _selectCoordinate(_center);
        if (mapLocation != null) {
          _addDescriptionPlace(mapLocation);
        }
      },
      child: Icon(Icons.add),
      backgroundColor: Theme.of(context).primaryColor,
      heroTag: null,
    );
  }

  void _showCurrentRoute(TrufiLocation toLocation) async {
    HomePageStateData dataRoute = HomePageStateData();
    final location = await LocationProviderBloc.of(context).currentLocation;
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
    final TrufiLocalization localization =
        TrufiLocalizations.of(context).localization;
    final SavedLocationsBloc savedLocationsBloc =
        SavedLocationsBloc.of(context);
    return await showDialog(
      context: context,
      child: SimpleDialog(
        title: Text(localization.savedSectionSelectIcon()),
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
                    savedLocationsBloc.inReplaceLocation
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

  Future<void> _changeCoordinate(TrufiLocation savedPlace) async {
    final SavedLocationsBloc savedLocationsBloc =
        SavedLocationsBloc.of(context);
    final LatLng mapLocation = await _selectCoordinate(
        LatLng(savedPlace.latitude, savedPlace.longitude));
    if (mapLocation != null) {
      final TrufiLocation newLocation = TrufiLocation(
        description: savedPlace.description,
        latitude: mapLocation.latitude,
        longitude: mapLocation.longitude,
        type: savedPlace.type,
      );

      savedLocationsBloc.inReplaceLocation.add(<String, TrufiLocation>{
        'oldLocation': savedPlace,
        'newLocation': newLocation
      });
      setState(() {});
    }
  }

  Future<void> _addDescriptionPlace(LatLng mapLocation) async {
    final SavedLocationsBloc savedLocationsBloc =
        SavedLocationsBloc.of(context);
    final ThemeData theme = Theme.of(context);
    final TrufiLocalization localization =
        TrufiLocalizations.of(context).localization;

    return await showDialog(
      context: context,
      child: SimpleDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        backgroundColor: theme.primaryColor,
        title: Text(
          localization.savedSectionInsertName(),
          style: TextStyle(
            fontSize: 20,
            color: theme.primaryTextTheme.body2.color,
          ),
        ),
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(20),
            height: 35,
            child: TextField(
              style: theme.textTheme.body2,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: theme.primaryColor)),
              ),
              controller: textController,
              maxLines: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                color: theme.backgroundColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  localization.savedSectionCancel(),
                  style: theme.textTheme.body2,
                ),
              ),
              RaisedButton(
                color: theme.backgroundColor,
                onPressed: () {
                  savedLocationsBloc.inAddLocation.add(TrufiLocation(
                    description: textController.text,
                    latitude: mapLocation.latitude,
                    longitude: mapLocation.longitude,
                    type: 'saved_place:map',
                  ));
                  textController.clear();
                  setState(() {});
                  Navigator.pop(context);
                },
                child: Text(
                  localization.commonOK(),
                  style: theme.textTheme.body2,
                ),
              ),
            ],
          )
        ],
      ),
    );
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

  Future<LatLng> _selectCoordinate(LatLng coordinate) {
    return Navigator.of(context).push(
      MaterialPageRoute<LatLng>(
        builder: (BuildContext context) =>
            ChooseLocationPage(initialPosition: coordinate),
      ),
    );
  }
}

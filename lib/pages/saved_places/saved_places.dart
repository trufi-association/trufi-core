import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/pages/saved_places/widgets/location_tiler.dart';
import 'package:trufi_core/repositories/location/location_repository.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/widgets/maps/choose_location/choose_location.dart';

class SavedPlacesPage extends StatefulWidget {
  static const String route = 'saved-places';

  const SavedPlacesPage({super.key});

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  final locationRepository = LocationRepository();
  @override
  void initState() {
    locationRepository.myPlaces.addListener(update);
    locationRepository.myDefaultPlaces.addListener(update);
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      await locationRepository.initLoad();
    });
    super.initState();
  }

  @override
  void dispose() {
    locationRepository.myPlaces.removeListener(update);
    locationRepository.myDefaultPlaces.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);
    final titleStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(localization.translate(LocalizationKey.yourPlacesMenu)),
          ],
        ),
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          children: [
            Column(
              children: locationRepository.myDefaultPlaces.value.map((place) {
                return LocationTiler(
                  location: place,
                  enableSetPosition: true,
                  isDefaultLocation: true,
                  updateLocation: locationRepository.updateMyDefaultPlace,
                  selectPositionOnPage: (context, {isOrigin, position}) =>
                      _selectPosition(
                        context,
                        isOrigin: isOrigin,
                        position: position, 
                        hideLocationDetails: true,
                      ),
                );
              }).toList(),
            ),
            if (locationRepository.myPlaces.value.isNotEmpty) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text("Custom Places", style: titleStyle),
              ),
            ],
            Column(
              children: locationRepository.myPlaces.value
                  .map(
                    (place) => LocationTiler(
                      location: place,
                      enableLocation: true,
                      updateLocation: locationRepository.updateMyPlace,
                      removeLocation: locationRepository.deleteMyPlace,
                      selectPositionOnPage: _selectPosition,
                    ),
                  )
                  .toList(),
            ),
            if (locationRepository.favoritePlaces.value.isNotEmpty) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text("Favorite Places", style: titleStyle),
              ),
            ],
            Column(
              children: locationRepository.favoritePlaces.value
                  .map(
                    (place) => LocationTiler(
                      location: place,
                      updateLocation: locationRepository.updateFavoritePlace,
                      removeLocation: locationRepository.deleteFavoritePlace,
                      selectPositionOnPage: _selectPosition,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewPlace(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addNewPlace(BuildContext context) async {
    final TrufiLocation? locationDetail = await _selectPosition(context);
    if (locationDetail != null) {
      locationRepository.insertMyPlace(
        TrufiLocation(
          description: locationDetail.description,
          address: locationDetail.address,
          position: locationDetail.position,
          type: TrufiLocationType.customPlace,
        ),
      );
    }
  }

  Future<TrufiLocation?> _selectPosition(
    BuildContext context, {
    bool? isOrigin,
    LatLng? position,
    bool? hideLocationDetails,
  }) async {
    return await ChooseLocationPage.selectLocation(
      context,
      position: position,
      isOrigin: isOrigin,
      hideLocationDetails: hideLocationDetails,
    );
  }
}

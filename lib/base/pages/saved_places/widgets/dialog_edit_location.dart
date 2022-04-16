import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';

class DialogEditLocation extends StatefulWidget {
  final TrufiLocation location;
  const DialogEditLocation({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  _DialogEditLocationState createState() => _DialogEditLocationState();
}

class _DialogEditLocationState extends State<DialogEditLocation> {
  final _formKey = GlobalKey<FormFieldState>();
  late TrufiLocation location;

  @override
  void initState() {
    location = widget.location;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final localizationSP = SavedPlacesLocalization.of(context);
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
          buttonPadding: EdgeInsets.zero,
          title: Text(
            localizationSP.savedPlacesEditLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizationSP.nameLabel,
                ),
                TextFormField(
                  key: _formKey,
                  initialValue: location.displayName(localizationSP),
                  decoration: InputDecoration(
                    hintText: localizationSP.savedPlacesEnterNameTitle,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    location = location.copyWith(description: value);
                  },
                  validator: (value) => _validateInput(value, localizationSP),
                  autocorrect: false,
                ),
                const SizedBox(height: 15),
                Text(
                  localizationSP.iconlabel,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  height: 40,
                  child: GridView.builder(
                    itemCount: listIconsPlace.length,
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                    ),
                    itemBuilder: (BuildContext builderContext, int index) {
                      final isSelected =
                          location.type == listIconsPlace.keys.elementAt(index);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            location = location.copyWith(
                                type: listIconsPlace.keys.elementAt(index));
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5)),
                          child: Icon(
                            listIconsPlace.values.elementAt(index),
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () async {
                    final LocationDetail? chooseLocationDetail =
                        await ChooseLocationPage.selectPosition(
                      context,
                      position: location.isLatLngDefined
                          ? LatLng(location.latitude, location.longitude)
                          : null,
                    );
                    if (chooseLocationDetail != null) {
                      location = location.copyWith(
                        longitude: chooseLocationDetail.position.longitude,
                        latitude: chooseLocationDetail.position.latitude,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(50, 35),
                    onPrimary: theme.colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        localizationSP.savedPlacesSetPositionLabel,
                        style: theme.textTheme.bodyText2,
                      ),
                      Icon(
                        Icons.edit_location_alt,
                        size: 20,
                        color: theme.iconTheme.color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                onPrimary: theme.colorScheme.primary,
              ),
              child: Text(
                localization.commonCancel.toUpperCase(),
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(location);
                }
              },
              style: ElevatedButton.styleFrom(
                onPrimary: theme.colorScheme.primary,
              ),
              child: Text(
                localization.commonSave.toUpperCase(),
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateInput(String? text, SavedPlacesLocalization localization) {
    String? result;
    if (text == null || text.isEmpty) {
      result = localization.savedPlacesEnterNameValidation;
    }
    return result;
  }
}

const listIconsPlace = <String, IconData>{
  'saved_place:map': Icons.map,
  'saved_place:home': Icons.home,
  'saved_place:work': Icons.work,
  'saved_place:fastfood': Icons.fastfood,
  'saved_place:local_cafe': Icons.local_cafe,
  'saved_place:school': Icons.school,
};

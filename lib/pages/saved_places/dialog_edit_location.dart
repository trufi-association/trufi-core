import 'package:flutter/material.dart';

import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:latlong2/latlong.dart';

import '../choose_location.dart';

class DialogEditLocation extends StatefulWidget {
  final TrufiLocation location;

  const DialogEditLocation({
    Key key,
    @required this.location,
  }) : super(key: key);

  @override
  _DialogEditLocationState createState() => _DialogEditLocationState();
}

class _DialogEditLocationState extends State<DialogEditLocation> {
  final _formKey = GlobalKey<FormFieldState>();
  TrufiLocation location;

  @override
  void initState() {
    location = widget.location;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text(
            // TODO translation
            localization.localeName == 'de' ? "Ort bearbeiten" : "Edit place",
            style: theme.textTheme.bodyText1.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
          buttonPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // TODO translation
                  "Name",
                  style: theme.textTheme.subtitle1,
                ),
                TextFormField(
                  key: _formKey,
                  initialValue: location.displayName(localization),
                  decoration: InputDecoration(
                    hintText: localization.savedPlacesEnterNameTitle,
                    hintStyle: theme.textTheme.subtitle1,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyText1.copyWith(fontSize: 16),
                  onChanged: (value) {
                    location = location.copyWith(description: value);
                  },
                  validator: (value) => _validateInput(value, localization),
                  autocorrect: false,
                ),
                const SizedBox(height: 15),
                Text(
                  // TODO translation
                  "Icon",
                  style: theme.textTheme.subtitle1,
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
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () async {
                    final ChooseLocationDetail chooseLocationDetail =
                        await ChooseLocationPage.selectPosition(
                      context,
                      position: location.isLatLngDefined
                          ? LatLng(location.latitude, location.longitude)
                          : null,
                    );
                    if (chooseLocationDetail != null) {
                      location = location.copyWith(
                        longitude: chooseLocationDetail.location.longitude,
                        latitude: chooseLocationDetail.location.latitude,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(50, 35),
                    onPrimary: theme.primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        localization.savedPlacesSetPositionLabel,
                        style: theme.textTheme.bodyText1,
                      ),
                      Icon(
                        Icons.edit_location_alt,
                        size: 20,
                        color: theme.textTheme.bodyText1.color,
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
                onPrimary: theme.primaryColor,
              ),
              child: Text(
                localization.commonCancel.toUpperCase(),
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Navigator.of(context).pop(location);
                }
              },
              style: ElevatedButton.styleFrom(
                onPrimary: theme.primaryColor,
              ),
              child: Text(
                localization.commonSave.toUpperCase(),
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _validateInput(String text, TrufiLocalization localization) {
    String result;
    if (text.isEmpty) {
      // TODO translation
      result = localization.localeName == 'de'
          ? "Der Name darf nicht leer sein"
          : "The name cannot be empty";
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

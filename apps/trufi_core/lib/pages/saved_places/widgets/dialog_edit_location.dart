import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/pages/saved_places/widgets/location_tiler.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class DialogEditLocation extends StatefulWidget {
  final TrufiLocation location;
  final SelectLocationData selectPositionOnPage;

  const DialogEditLocation({
    super.key,
    required this.location,
    required this.selectPositionOnPage,
  });

  @override
  State<DialogEditLocation> createState() => _DialogEditLocationState();
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
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          titlePadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
          buttonPadding: EdgeInsets.zero,
          title: Text(
            "Edit place",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Name"),
                TextFormField(
                  key: _formKey,
                  initialValue: location.description,
                  decoration: InputDecoration(
                    hintText: "Enter name",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    location = location.copyWith(description: value);
                  },
                  validator: (value) => _validateInput(value),
                  autocorrect: false,
                ),
                const SizedBox(height: 15),
                Text("Icon"),
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
                          location.type.value == listIconsPlace.keys.elementAt(index);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            location = location.copyWith(
                              type: TrufiLocationType.fromString(
                                listIconsPlace.keys.elementAt(index),
                              ),
                            );
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
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
                    final TrufiLocation? chooseLocationDetail = await widget
                        .selectPositionOnPage(
                          context,
                          position: location.isLatLngDefined
                              ? location.position
                              : null,
                        );
                    if (chooseLocationDetail != null) {
                      location = location.copyWith(
                        position: LatLng(
                          chooseLocationDetail.position.latitude,
                          chooseLocationDetail.position.longitude,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(50, 35),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Set position", style: theme.textTheme.bodyMedium),
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
                foregroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.textTheme.displayLarge?.color),
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
                foregroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                "Save",
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateInput(String? text) {
    String? result;
    if (text == null || text.isEmpty) {
      result = "The name is Required";
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

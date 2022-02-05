import 'package:flutter/material.dart';

import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';

class DialogSelectIcon extends StatelessWidget {
  static const icons = <String, IconData>{
    'saved_place:home': Icons.home,
    'saved_place:work': Icons.work,
    'saved_place:fastfood': Icons.fastfood,
    'saved_place:local_cafe': Icons.local_cafe,
    'saved_place:map': Icons.map,
    'saved_place:school': Icons.school,
  };

  const DialogSelectIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationSp = SavedPlacesLocalization.of(context);
    return SimpleDialog(
      title: Text(
        localizationSp.savedPlacesSelectIconTitle,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      children: <Widget>[
        SizedBox(
          width: 200,
          height: 200,
          child: GridView.builder(
            itemCount: icons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4),
            itemBuilder: (BuildContext builderContext, int index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop(icons.keys.elementAt(index));
                },
                child: Icon(icons.values.elementAt(index)),
              );
            },
          ),
        ),
      ],
    );
  }
}

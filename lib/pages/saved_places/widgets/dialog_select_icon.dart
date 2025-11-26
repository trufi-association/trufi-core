import 'package:flutter/material.dart';

class DialogSelectIcon extends StatelessWidget {
  static const icons = <String, IconData>{
    'saved_place:home': Icons.home,
    'saved_place:work': Icons.work,
    'saved_place:fastfood': Icons.fastfood,
    'saved_place:local_cafe': Icons.local_cafe,
    'saved_place:map': Icons.map,
    'saved_place:school': Icons.school,
  };

  const DialogSelectIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        "Select icon",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      children: <Widget>[
        SizedBox(
          width: 200,
          height: 200,
          child: GridView.builder(
            itemCount: icons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
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

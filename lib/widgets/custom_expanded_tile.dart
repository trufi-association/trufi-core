import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final List<String> options;
  final String textSelected;
  final Function(String) onChanged;

  const CustomExpansionTile({
    Key key,
    @required this.title,
    @required this.options,
    @required this.textSelected,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: theme.textTheme.bodyText1)),
          Text(
            textSelected,
            style: TextStyle(
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
      children: options
          .map(
            (option) => Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: ListTile(
                tileColor: theme.textTheme.bodyText1.color.withOpacity(0.05),
                visualDensity: VisualDensity.compact,
                title: Text(
                  option,
                  style: TextStyle(
                    color: theme.primaryColor,
                  ),
                ),
                trailing: option.toLowerCase() == textSelected.toLowerCase()
                    ? Icon(
                        Icons.check,
                        color: theme.accentColor,
                      )
                    : null,
                onTap: () {
                  onChanged(option);
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

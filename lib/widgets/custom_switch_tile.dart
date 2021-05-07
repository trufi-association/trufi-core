import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {
  const CustomSwitchTile({
    Key key,
    @required this.title,
    @required this.value,
    @required this.onChanged,
    this.secondary,
  }) : super(key: key);
  final String title;
  final Widget secondary;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      title: Text(title, style: theme.textTheme.bodyText1),
      secondary: secondary,
      activeColor: theme.primaryColor,
      value: value,
      onChanged: onChanged,
    );
  }
}

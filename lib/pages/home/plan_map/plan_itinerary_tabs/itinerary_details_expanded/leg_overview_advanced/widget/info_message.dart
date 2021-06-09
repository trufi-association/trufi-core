import 'package:flutter/material.dart';

class InfoMessage extends StatelessWidget {
  final String message;
  const InfoMessage({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color(0xffe5f2fa),
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: theme.primaryColor,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Text(
                  message,
                  style: theme.textTheme.bodyText1.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
